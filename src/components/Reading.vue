<template>
  <div>
    <h3>Currently Reading</h3>
    <!-- <p>Total: {{readingcount}}</p> -->
    <form id="formbox">
      <md-field class="formboxes" md-inline>
        <label class="formboxes">Add a book you are reading</label>
        <md-input id="inputfield" value class="formboxes"></md-input>
        <md-button
          v-on:click="addedbook"
          class="md-raised md-primary md-mini addbookbutn formboxes"
        >Add +</md-button>
      </md-field>
      <md-list>
        <md-list-item
          class="listofbooks"
          v-for="book in books"
          v-bind:key="book.id"
          v-bind:title="book.title"
          @click="addedbook"
        >{{book.title}}</md-list-item>
      </md-list>
      <md-button
        
        class="md-raised green-butn md-mini formboxes"
      >Finished Reading</md-button>
      <md-button v-on:click="deletebook" class="md-raised md-accent md-mini formboxes">Delete</md-button>
    </form>
  </div>
</template>

<script lang="ts">
// let nextToreadId = 1;

export default {
  name: "Toread",
  props: {
    toreadcount: Number,
    title: String,
    value: {
      type: String,
      default: "",
    },
  },
  data() {
    return {
      newReadingText: "",
      books: [],
    };
  },
  methods: {
    addedbook() {
      // const trimmedText = this.newToreadText.trim();
      // const inputfromfield = document.getElementById("inputfield").value;
      // console.log(inputfromfield);
      console.log('book added');

      // this.books.push({
      //   id: nextToreadId++,
      //   title: inputfromfield,
      // });
      // this.newReadingText = "";
    },
    readingbook: function () {
      console.log("added book to reading list");
    },
    deletebook: function () {
      console.log("deleted book from list");
    },
  },
};
</script>

<style scoped>
h3 {
  margin: 40px 0 0;
}
a {
  color: #42b983;
}
#formbox {
  padding-left: 20%;
  padding-right: 20%;
}
.formboxes {
  background-color: white;
}
.green-butn {
  background-color: yellowgreen !important;
  color: white !important;
}
label {
  padding-left: 1em;
}
.addbookbutn {
  margin-top: -10px;
}
</style>
