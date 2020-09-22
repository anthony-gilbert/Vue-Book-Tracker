<template>
  <div id="app">
    <img
      id="book-icon"
      alt="Book Icon."
      src="https://www.graphicsfuel.com/wp-content/uploads/2012/07/books-icon-512.png"
    />
    <Header msg="Book Tracker" />
    <Toread v-bind:toreadcount="2" v-bind:toreadlist="toreads" />
    <Reading v-bind:readingcount="5" v-bind:readinglist="readings" />
    <Read v-bind:readcount="5" v-bind:readlist="reads" />
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
  },
  data() {
    return {
      roreads: [
        {
          title: "Todo A",
          project: "Project A",
          done: false,
        },
        {
          title: "Todo B",
          project: "Project B",
          done: true,
        },
        {
          title: "Todo C",
          project: "Project C",
          done: false,
        },
        {
          title: "Todo D",
          project: "Project D",
          done: false,
        },
        {
          title: "Extira Item",
          project: "Project Description",
          done: true,
        },
      ],
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
  width: 200px;
  height: 200px;
}
</style>
