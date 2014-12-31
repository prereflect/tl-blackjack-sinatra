$(document).ready(function() {

  $(document).on('click', '#hit_form input', function(){
    $.ajax({
      type: 'POST',
      url: '/player/hit'
    }).done(function(msg) {
      $('#game').replaceWith(msg);
    });
    return false;
  });

  $(document).on('click', '#stay_form input', function(){
    $.ajax({
      type: 'GET',
      url: '/player/stay'
    }).done(function(msg) {
      $('#game').replaceWith(msg);
    });
    return false;
  });
});

