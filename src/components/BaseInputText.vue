<template>

<!-- <md-field class="formboxes" md-inline> -->
       <input
    type="text"
    id="inputbook"
    class="input formboxes md-field formboxes md-theme-default md-inline"
    :value="value"
    v-on="listeners"/>
       <!-- </md-field> -->
</template>

<script>
export default {
  props: {
    value: {
      type: String,
      default: '',
    }
  },
  computed: {
    listeners () {
      return {
        // Pass all component listeners directly to input
        ...this.$listeners,
        // Override input listener to work with v-model
        input: event => this.$emit('input', event.target.value)
      }
    }
  }
}
</script>

<style scoped>
#inputbook{
      height: 32px;
    padding: 0;
    display: block;
    flex: 1;
    border: none;
    background: none;
    transition: .4s cubic-bezier(.25,.8,.25,1);
    transition-property: font-size,padding-top,color;
    font-family: inherit;
    font-size: 16px;
    line-height: 32px;
    background-color: white;
    box-sizing: inherit;
}

.formbox {
  padding-left: 20%;
  padding-right: 20%;
}

.formboxes {
  background-color: white;
}

</style>
