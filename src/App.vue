<template>
  <div id="app">
    <img id="book-icon" alt="Vue logo" src="https://www.graphicsfuel.com/wp-content/uploads/2012/07/books-icon-512.png">
    <HelloWorld msg="Book Tracker"/>
  </div>
</template>

<script>
import HelloWorld from './components/HelloWorld.vue'

export default {
  name: 'App',
  components: {
    HelloWorld
  }
}
</script>

<style>
#app {
  font-family: Avenir, Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  text-align: center;
  color: #2c3e50;
  margin-top: 60px;
}
#book-icon {
  width: 200px;
  height: 200px;
}
</style>
