var numrefreshes = 0

$(document).ajaxStart(function () {
	$('#activity').show();
}).ajaxStop(function (){
	$('#activity').hide();
});

function scrollToBottom() {
	$("#updates").scrollTo(document.getElementById("updates").scrollHeight, 300, {queue:false})
}

function refreshUpdates() {
	//alert(updatefilter);
	
	origsh = $("#updatespane").attr("scrollTop");scrollToBottom();
	origheight = $("#updatespane").attr("scrollHeight")
	compheight = parseInt(getComputedHeight('updatespane'))
	actheight = origsh + compheight
	
	// $.ajax({
	// 	type: "POST",
	// 	url: "/gameroom/fetchupdates/",
	// 	data: "gameid=" + gameid,
	// 	success: function(msg){
	// 		$("#updatespane").html(msg)
	// 
	// 		if(actheight == origheight) {
	// 			scrollToBottom();
	// 		}
	// 		
	// 		if(numrefreshes==0) {
	// 			scrollToBottom();
	// 		}
	// 		
	// 		numrefreshes = numrefreshes + 1;
	// 		
	// 		jQuery('span[class*=timeago]').timeago();
	// 	}
	// });
}

function switchfilter(filterid) {
	updatefilter = filterid;
	$('.menuon').removeClass('menuon').addClass('menuoff');
	$('#filter-'+filterid).removeClass('menuoff');
	$('#filter-'+filterid).addClass('menuon');
}

function sendUpdate() {
	origsh = $("#updatespane").attr("scrollHeight")
	update = document.getElementById('updatetext').value
	//alert(update)
	document.getElementById('updatetext').disabled = true
	document.getElementById('updatetext').blur()
	
	$.ajax({
		type: "POST",
		url: "/gameroom/sendupdate/",
		data: "gameid=" + gameid + "&text=" + escape(update),
		success: function(msg){
			//$("#updatespane").html(msg)
			document.getElementById('updatetext').disabled = false;
			document.getElementById('updatetext').value = '';
			document.getElementById('updatetext').focus();
			
			scrollToBottom();
		}
	});
	
	if(origsh == 0) {
		scrollToBottom();
	}
}

$(function() {
$('#updatetext').keyup(function(e) {
	if(e.keyCode == 13) {
		sendUpdate();
	}
	});
});

function toggleHideTwitter() {
	if (src_twitter==1) {
		$('.src_twitter').hide();
		src_twitter = 0;	
		$('#hidetwitter').text('show Twitter updates')
	} else {
		$('.src_twitter').show();
		src_twitter = 1;
		$('#hidetwitter').text('hide Twitter updates')
	}
}

// $(function() {
// 	$('a.remote').remote('#updatespane', function() {
// 	 	if (window.console && window.console.info) {
// 	 		console.info('content loaded');
// 	 	}
//  	}); 
// 	$.ajaxHistory.initialize();
// });

$(function() {
	$('a.update_content_reply_to').live('click', function() {
	  window.scrollTo(0, 0);
	  var pieces = $(this).attr('rel').split(':');
	  var screen_name = pieces[0];
	  var id = pieces[1];
	  $('#update_content').focus().val('@' + screen_name + ' ');
	  $('#update_in_reply_to_update_id').val(id);
	  $('#update_in_reply_to_user').val(screen_name);
	  return false;
	});
});
// 
// function getUrlVars()
// {
//     var vars = [], hash;
//     var hashes = window.location.href.slice(window.location.href.indexOf('?') + 1).split('&');
//     for(var i = 0; i < hashes.length; i++)
//     {
//         hash = hashes[i].split('=');
//         vars.push(hash[0]);
//         vars[hash[0]] = hash[1];
//     }
//     return vars;
// }

// $(function() {
// 	var in_reply_to = getUrlVars()["in_reply_to"];	
// 	var in_reply_to_update_id = getUrlVars()["in_reply_to_update_id"];
// 	var game_id = getUrlVars()["game_id"];	
// 	
// 	if (document.referrer.indexOf(game_id) == -1) { 
// 	
// 		if (in_reply_to.length > 0) {
// 			$('#update_content').focus().val('@' + in_reply_to + ' ');
// 			$('#update_in_reply_to_update_id').val(in_reply_to_update_id);
// 			$('#update_in_reply_to_user').val(in_reply_to)
// 		} else {
// 			return false;
// 		}
// 	} else {
// 		return false;
// 	}
// });

function taba(newid) {
	$(".atabcurrent").removeClass("atabcurrent")
	$("#" + newid).addClass("atabcurrent")
}

$(document).bind('beforeReveal.facebox', function() {
    $("#facebox .content").empty();
});