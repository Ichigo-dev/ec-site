$(".edit-link").click(function(){
  address_id=$(this).data('id');
  $address_edit=$("#address-edit-"+address_id);
  $address=$("#address-"+address_id);
  console.log($address)
  $('.address-data').show();
  $(".edit").hide();
  $address.hide();
  $address_edit.show();
})

$(".address-edit-back").click(function(){
  $('.address-data').show();
  $('.edit').hide();
})
