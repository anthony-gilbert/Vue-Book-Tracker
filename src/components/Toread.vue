<template>
  <div>
    <h3>To Read</h3>
    <p>Total: {{readingcount}}</p>
    <form id="formbox" @submit="onSubmit">
      <md-field class="formboxes" md-inline>
        <label class="formboxes"> Add a book you want to read</label>
        <md-input class="formboxes" v-model="inline"></md-input>
        <md-button v-on:click="addedbook" class="md-raised md-primary md-mini formboxes">Add +</md-button>
      </md-field>
      <md-list>
        <md-list-item
          class="listofbooks"
          v-for="book in books"
          v-bind:key="book.id"
          @click="alert"
        >{{book.title}}</md-list-item>
      </md-list>
      <md-button v-on:click="readingbook" class="md-raised green-butn md-mini formboxes">Reading</md-button>
      <md-button v-on:click="deletebook" class="md-raised md-accent md-mini formboxes">Delete</md-button>
    </form>
  </div>
</template>

<script lang="ts">
export default {
  name: "Toread",
  props: {
    toreadcount: Number
  },
  data() {
    return {
      books: [{ title: 'Harry Potter' }, { title: 'The Giver' }]
    }
  },
  methods: {
    addedbook: function (event) {
      console.log('book added');
    },
    readingbook: function (event) {
      console.log('added book to reading list');
    },
    deletebook: function(event) {
      console.log('deleted book from list');
    }
  }
};

</script>

<style>
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
</style>
