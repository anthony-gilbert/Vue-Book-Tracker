<template>
  <div id="app">
    <img id="book-icon" alt="Book Icon." src="https://www.graphicsfuel.com/wp-content/uploads/2012/07/books-icon-512.png">
    <HelloWorld msg="Book Tracker"/>
    <Toread v-bind:toreadcount="2"/>
    <Reading v-bind:readingcount="5"/>
    <Read v-bind:readcount="5"/>
    <Footer />
  </div>
</template>

<script>
import HelloWorld from './components/HelloWorld.vue'
import Toread from './components/Toread.vue'
import Reading from './components/Reading.vue'
import Read from './components/Read.vue'
import Footer from './components/Footer.vue'

export default {
  name: 'App',
  components: {
    HelloWorld,
    Toread,
    Reading,
    Read,
    Footer
  },
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
