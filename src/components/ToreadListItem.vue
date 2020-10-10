<template>
  <md-list-item>
    {{ toread.text }}
    <button id="deletebutton" @click="$emit('remove', toread.id)">
      Delete
    </button>
  </md-list-item>
</template>

<script>
export default {
  props: {
    toread: {
      type: Object,
      required: true,
    },
  },
};
</script>
<style>
#deletebutton {
  padding: 0 8px;
  display: flex;
  justify-content: center;
  align-items: center;
  background-color: #ff5252;
  min-width: 88px;
  height: 36px;
  margin: 6px 8px;
  -webkit-user-select: none;
  -ms-user-select: none;
  user-select: none;
  border-radius: 2px;
  font-size: 14px;
  font-weight: 500;
  text-transform: uppercase;
  color: white;
  border: 0px;
  cursor: pointer;
}
</style>