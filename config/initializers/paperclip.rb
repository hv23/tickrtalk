module Paperclip
  module ClassMethods
    def has_attached_file name, options = {}
      include InstanceMethods
 
      write_inheritable_attribute(:attachment_definitions, {}) if attachment_definitions.nil?
      attachment_definitions[name] = {:validations => []}.merge(options)
 
      after_save :save_attached_files
      before_destroy :destroy_attached_files
 
      define_callbacks :before_post_process, :after_post_process
      define_callbacks :"before_#{name}_post_process", :"after_#{name}_post_process"
     
      define_method name do |*args|
        a = attachment_for(name)
        (args.length > 0) ? a.to_s(args.first) : a
      end
 
      define_method "#{name}=" do |file|
        attachment_for(name).assign(file)
      end
 
      define_method "#{name}?" do
        attachment_for(name).file?
      end
 
      validates_each name, :logic => lambda {
        attachment = attachment_for(name)
        attachment.send(:flush_errors) unless attachment.valid?
      }
    end
  end
 
  module Interpolations
    # Handle string ids (mongo)
    def id_partition attachment, style
      if (id = attachment.instance.id).is_a?(Integer)
        ("%09d" % id).scan(/\d{3}/).join("/")
      else
        id.scan(/.{3}/).first(3).join("/")
      end
    end
  end
  
  class Attachment
    def assign_with_dimensions uploaded_file
      assign_without_dimensions uploaded_file

      begin
        d = Geometry.from_file @queued_for_write[:original]
        @instance.width = d.width if @instance.respond_to? :width
        @instance.height = d.height if @instance.respond_to? :height
      rescue Paperclip::NotIdentifiedByImageMagickError
      end
    end
    alias_method_chain :assign, :dimensions
    
    def content_type
      Array(MIME::Types.type_for(original_filename)).first.to_s
    end
  end
  
  module Storage
    module Gridfs
      def self.extended base
        begin
          require 'mongo'
          require 'mongo/gridfs'
          
          include ::GridFS
        rescue LoadError => e
          e.message << " (You may need to install the mongo gem)"
          raise e
        end

        base.instance_eval do
          @gridfs_options = parse_credentials(@options[:gridfs])
          @gridfs_db      = Paperclip::Storage::Gridfs.gridfs_connections(@gridfs_options)
        end
      end
      
      def self.gridfs_connections creds
        @connections ||= {}
        @connections[creds] ||= get_database_connection(creds)
      end
      
      def connection
        @gridfs_db
      end
      
      def parse_credentials creds
        creds = find_credentials(creds).stringify_keys
        (creds[RAILS_ENV] || creds).symbolize_keys
      end
      
      def exists?(style = default_style)
        if original_filename
          GridStore.exist?(connection, path(style))
        else
          false
        end
      end

      # Returns representation of the data of the file assigned to the given
      # style, in the format most representative of the current storage.
      def to_file style = default_style
        @queued_for_write[style] || (GridStore.open(connection, path(style), 'r') if exists?(style))
      end

      def flush_writes #:nodoc:
        @queued_for_write.each do |style, file|
          log("saving #{path(style)} as #{content_type}")
          
          GridStore.open(connection, path(style), 'w', {
              :content_type => content_type,
              :metadata => { 'instance_id' => instance.id },
              :chunk_size => 4.kilobytes
            }) { |f|
            f.write file.read
          }
          file.close
          File.unlink(file.path)
        end
        @queued_for_write = {}
      end

      def flush_deletes #:nodoc:
        @queued_for_delete.each do |path|
          begin
            log("deleting #{path}")
            GridStore.unlink(connection, path) if GridStore.exist?(connection, path)
          rescue Errno::ENOENT => e
            # ignore file-not-found, let everything else pass
          end
        end
        @queued_for_delete = []
      end
      
      def self.get_database_connection creds
        case creds[:database]
        when Mongo::DB then creds[:database]
        else
          returning Mongo::Connection.new(creds[:host] || "localhost", creds[:port] || Mongo::Connection::DEFAULT_PORT).db(creds[:database]) do |db|
            if creds[:username] && creds[:password]
              auth = db.authenticate creds[:username], creds[:password]
            end
          end
        end
      end

      def find_credentials creds
        case creds
        when File
          YAML::load(ERB.new(File.read(creds.path)).result)
        when String
          YAML::load(ERB.new(File.read(creds)).result)
        when Hash
          creds
        else
          raise ArgumentError, "Credentials are not a path, file, or hash."
        end
      end
      private :find_credentials
    end
    
  end
  
  def self.logger
    Rails.logger
  end
end

Paperclip.interpolates :category do |attachment, style|
  attachment.instance.project.category.to_param
end

Paperclip.interpolates :project do |attachment, style|
  attachment.instance.project_id.to_s
end

File.send(:include, Paperclip::Upfile)