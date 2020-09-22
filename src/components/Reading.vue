<template>
  <div id="app">
    <h3>Reading</h3>
    <p>Total: {{readingcount}}</p>
    <form id="formbox" @submit="onSubmit">
      <md-field class="formboxes" md-inline>
        <label class="formboxes"> Add a book you are reading</label>
        <md-input class="formboxes" v-model="inline"></md-input>
        <md-button class="md-raised md-primary md-mini formboxes">Add + </md-button>
      </md-field>
    </form>
    <ul>
      <li>Book Title</li>
      <li>Book Title</li>
      <li>Book Title</li>
      <li>Book Title</li>
      <li>Book Title</li>
    </ul>
  </div>
</template>

<script>

export default {
  name: 'Reading',
  props: {
    readingcount: Number,
    readinglist: []
  }
}
</script>

<style>
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
</style>
