<template>
  <div>
    <h3>To Read</h3>
    <p>Total: {{readingcount}}</p>
    <form id="formbox" @submit="onSubmit">
      <md-field class="formboxes" md-inline>
        <label class="formboxes">Add a book you want to read</label>
        <md-input @keydown.enter="addedbook" v-model="newToreadText " ></md-input>
    
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
          @click="alert"
        >{{book.title}}</md-list-item>
      </md-list>
      <md-button
        v-on:click="readingbook"
        class="md-raised green-butn md-mini formboxes"
      >Add to Reading</md-button>
      <md-button v-on:click="deletebook" class="md-raised md-accent md-mini formboxes">Delete</md-button>
    </form>
  </div>
</template>

<script lang="ts">

// let newToreadId = 1;

export default {
  name: "Toread",
  props: {
    value: {
      type: String,
      default: '',
    }
  },
  computed: {
    listeners() {
      return {
        // Pass all component listeners directly to input
        ...this.$listeners,
        // Override input listener to work with v-model
        input: (event) => this.$emit("input", event.target.value),
      };
    },
  },
  data() {
    return {
      // newToreadText: "",
      books: [],
    };
  },
  methods: {
    addedbook() {
      // const newToreadText = "";
      const trimmedText = this.newToReadText.trim();
      const inputfromfield = document.getElementById("inputfield").value;
      console.log(inputfromfield);
      console.log('a book has been added');

      if (trimmedText) {
        this.books.push({
          title: inputfromfield,
        });
        this.newToReadText = "";
      }
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
