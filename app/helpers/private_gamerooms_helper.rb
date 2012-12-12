module PrivateGameroomsHelper
  def private_gameroom_stomp(channel, username)
    "$(document).ready(function(){
  		if (window.location.hash == '#replies') {
            document.domain = document.domain;
            stomp = new STOMPClient();
            stomp.onmessageframe = function(frame) {eval(frame.body)};
            stomp.onconnectedframe = function(frame){stomp.subscribe('/topic/private_gameroom_#{channel}_#{username}')};
            stomp.connect('#{OrbitedConfig.stomp_host}', 61613, '', '');
            $(window).bind('beforeunload', function() {stomp.reset()})}   
      } else if (window.location.hash == '#following')  {
            document.domain = document.domain;
            stomp = new STOMPClient();
            stomp.onmessageframe = function(frame) {eval(frame.body)};
            stomp.onconnectedframe = function(frame){stomp.subscribe('/topic/private_gameroom_#{channel}_#{username}_following')};
            stomp.connect('#{OrbitedConfig.stomp_host}', 61613, '', '');
            $(window).bind('beforeunload', function() {stomp.reset()});
      }   else if (window.location.hash != '#following') || if (location.hash != '#replies') {
            document.domain = document.domain;
            stomp = new STOMPClient();
            stomp.onmessageframe = function(frame) {eval(frame.body)};
            stomp.onconnectedframe = function(frame){stomp.subscribe('/topic/private_gameroom_#{channel}')};
            stomp.connect('#{OrbitedConfig.stomp_host}', 61613, '', '');
            $(window).bind('beforeunload', function() {stomp.reset()});
      }
  	});"
  end
end
