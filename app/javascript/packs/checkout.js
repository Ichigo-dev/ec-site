var postal_code = document.getElementsByClassName("postal_code");
for(var i = 0; postal_code[i] != null; i++){
  postal_code[i].textContent="〒"+postal_code[i].textContent.slice(0,3)+"-"+postal_code[i].textContent.slice(3,7);
}


