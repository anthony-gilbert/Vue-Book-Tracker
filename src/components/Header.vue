<template>
  <div class="md-layout md-gutter mdc-top-app-bar header-class md-elevation-1">
       <md-avatar id="avataricon">
    <img
      class="md-layout-item"
      id="book-icon"
      alt="Book Icon."
      src="https://www.graphicsfuel.com/wp-content/uploads/2012/07/books-icon-512.png"
    />
       </md-avatar>
    <h1 class="md-layout-item" >{{ msg }}</h1>
    
  </div>
</template>

<script>
export default {
  name: "Header",
  props: {
    msg: String,
  },
};
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style>
h1{
  color: aliceblue;
  margin-left: -50px;
}
h3 {
  margin: 40px 0 0;
}
ul {
  list-style-type: none;
  padding: 0;
}
li {
  display: inline-block;
  margin: 0 10px;
}
a {
  color: #147449;
}
.header-class {
  background-color: teal;
}
#book-icon {
  width: 50px;
  height: 50px;
  padding-left: 5%;
  margin-left: 0%;
}
#avataricon{
  margin-left: 50px;
}
</style>
