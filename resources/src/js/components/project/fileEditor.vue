<template>
  <div class="file_editor">
    <p>Файл: {{ filename }}</p>
    <p v-if="commit"><a :href="`/project/${namespace}/${name}/commit/${commit.hash}`">{{ commit.message }}</a> {{ commit.author_date }}</p>
    <div id="ace_editor" v-if="mimeType == 'text/plain'">{{ contents }}</div>
    <div class="row mt-3">
      <div class="col-md-3">
        <button class="btn btn-primary" @click="updateFile">Изменить</button>
      </div>
      <div class="col-md-9">
        <input type="text" v-model="commitMesage" class="form-control">
      </div>
    </div>
    
  </div>
</template>

<script>
  export default {
    props: [
      'name',
      'namespace',
      'filename',
      'commit',
      'branch',
    ],
    data () {
      return {
        contents: null,
        editor: null,
        mimeType: null,
        commitMesage: "",
      }      
    },
    watch: { 
      branch: function(newVal, oldVal) { // watch it
        console.log('Prop changed: ', newVal, ' | was: ', oldVal)
        this.getFileContents()
      }
    },
    methods: {
      getFileContents() {
        let self = this        
        if (self.editor) {
          self.editor.destroy()
          self.contents = null
          self.mimeType = null
        }
        self.commitMesage = "Изменен файл " + self.filename

        $.get(`/project/${self.namespace}/${self.name}/branch/${self.branch}/file/contents/${self.filename}`, function(data) {
          self.contents = data.contents
          self.mimeType = data.mime_type

          if (self.mimeType == 'text/plain') {
            self.$nextTick(() => {
              if (window.ace) {
                self.initAce()  
              } else {
                setTimeout(() => {
                  self.initAce()  
                }, 500)
              }              
            })            
          }
        })
      },
      initAce() {
        this.editor = ace.edit("ace_editor");
        this.editor.setTheme("ace/theme/monokai");
        this.editor.session.setMode("ace/mode/javascript");

        let modelist = ace.require("ace/ext/modelist")        
        let mode = modelist.getModeForPath(this.filename).mode
        this.editor.session.setMode(mode)
        // this.editor.setOptions({
        //     maxLines: Infinity
        // });
      },
      updateFile() {
        $.post(`/project/${this.namespace}/${this.name}/edit/${this.branch}${this.filename}`, {
          content: this.editor.getValue(),
          message: this.commitMesage,
        }, (data) => {
          console.log(data)
          this.getFileContents()
        }).catch((e) => {
          console.log(e)
          alert(e)
        })
      }
    },
    mounted() {
      this.getFileContents()
    }
  }
</script>
