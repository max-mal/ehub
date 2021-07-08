<template>
  <div class="branch_list">
      <input class="form-control" placeholder="Поиск" v-model="search">
      <div class="branch_list__item" v-for="branch in branches" :key="branch" @click="branchClick(branch)"
        v-if="!search.trim().length || branch.toLowerCase().includes(search.toLowerCase())">
        {{ branch }}
      </div>
  </div>
</template>

<script>
  export default {
    props: [
      'name',
      'namespace',
    ],
    data () {
      return {
        branches: [],
        search: "",
      }
    },
    methods: {
      branchClick(branch) {
        eventBus.$emit("branch_changed", branch)
      }
    },
    mounted: function() {
      let self = this
      $.get(`/project/${self.namespace}/${self.name}/branch/all`, function(data) {
        self.branches = data
      })
    }
  }
</script>
