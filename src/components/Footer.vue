<template>
  <dmd-bottom-bar-item id="app">
  <p class="mt-5 mb-3 text-muted footer-class">Made with <img alt="Vue logo" src="../assets/logo.png"/>ue.js  by Anthony Gilbert</p>
  </dmd-bottom-bar-item>
</template>





<script>

export default {
  name: 'Footer',
  props: {}
}

</script>




<style>
img {
  width: 20px;
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
  color: #42b983;
}
.footer-class {
  /* background-color: teal; */
  background-color: #ffffff;
  line-height: initial;
  margin-top: 7%;
  padding-top: 3%;
  padding-bottom: 3%;
  position: absolute;
  bottom: 0;
  width: 100%;
  margin-bottom: 0;
  box-shadow: 2px 0px 0 0px rgb(0 0 0 / 20%), 1px 1px 3px 0px rgb(0 0 0 / 14%), 3px 1px 0 0 rgb(0 0 0 / 12%);
}
</style>
