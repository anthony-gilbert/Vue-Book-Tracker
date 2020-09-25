<template>
  <div id="app">
    <img
      id="book-icon"
      alt="Book Icon."
      src="https://www.graphicsfuel.com/wp-content/uploads/2012/07/books-icon-512.png"
    />
     <!-- <md-app md-waterfall md-mode="fixed"> -->
      <Header msg="Book Tracker" />
      <Toread v-bind:toreadcount="2" v-bind:toreadlist="toreads" />
      <Reading v-bind:readingcount="5" v-bind:readinglist="readings" />
      <Read v-bind:readcount="5" v-bind:readlist="reads" />
    <!-- </md-app> -->
    <Footer />
    
  </div>
</template>

<!--
    <md-menu md-direction="bottom-start">
      <md-button md-menu-trigger>Bottom Start</md-button>

      <md-menu-content>
        <md-menu-item>My Item 1</md-menu-item>
        <md-menu-item>My Item 2</md-menu-item>
        <md-menu-item>My Item 3</md-menu-item>
      </md-menu-content>
    </md-menu>
 -->

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
  },
  data() {
    return {
      toreads: [],
    };
  },
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
#book-icon {
  width: 50px;
  height: 50px;
  padding-left: 0%;
  margin-left: 0%;

}
</style>
