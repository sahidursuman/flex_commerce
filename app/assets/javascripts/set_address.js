document.addEventListener("turbolinks:load", function() {
  
  console.log('working');
  $('#cities_select').empty();
  $('#cities_select').append($('<option value=""></option>'));
  <% @cities.each do |city| %>
    $('#cities_select').append($('<option <%= 'selected' if city == @city %> value="<%= city.id %>"><%= city.name %></option>'));
  <% end %>
  
  $('#districts_select').empty();
  $('#districts_select').append($('<option value=""></option>'));
  <% @districts.each do |district| %>
    $('#districts_select').append($('<option <%= 'selected' if district == @district %> value="<%= district.id %>"><%= district.name %></option>'));
  <% end %>
  
  $('#communities_select').empty();
  $('#communities_select').append($('<option value=""></option>'));
  <% @communities.each do |community| %>
    $('#communities_select').append($('<option value="<%= community.id %>"><%= community.name %></option>'));
  <% end %>
});