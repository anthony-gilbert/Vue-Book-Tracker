<template>
  <div id="app">
     <!-- <md-app md-waterfall md-mode="fixed"> -->
      <Header msg="Book Tracker" />
      <Toread v-bind:toreadcount="2" />
      <Reading v-bind:readingcount="5" />
      <Read v-bind:readcount="5" />
    <!-- </md-app> -->
    <Footer />
    
  </div>
</template>

<script>
// import Vue from 'vue'
import Header from "./components/Header.vue";
import Toread from "./components/Toread.vue";
import Reading from "./components/Reading.vue";
import Read from "./components/Read.vue";
import Footer from "./components/Footer.vue";

export default {
  name: "App",
  components: {
    Header,
    Toread,
    Reading,
    Read,
    Footer,
  }
};
</script>

<style>
body {
  margin: 0;
}
#app {
  font-family: Avenir, Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  text-align: center;
  color: #2c3e50;
  background-color: cadetblue;
}

</style>
