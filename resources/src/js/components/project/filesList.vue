<template>
  <div class="files_list">
    <div class="row files_list__branch">
      <div class="col-md-12">
        Ветка: {{ branch }}
        <p>
          <span class="files_list__dir" v-for="sub,index in directory.split('/')" @click="goToDirectory(index)">{{ sub }}/</span>
        </p>
      </div>
    </div>
      <div class="row files_list__header" v-if="!editingFile">
        <div class="col-md-3">
          Наименование
        </div>        
        <div class="files_list__item__commit col-md-6"">
          Последний коммит
        </div>
        <div class="files_list__item__updated_at col-md-3">
          Обновлено в
        </div>
      </div>

      <div class="files_list__item row" v-if="!editingFile && !loading && directory != ''" @click="parentDirectoryClick()">
        <div class="col-md-3">
          <div class="files_list__item__icon">          
            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" class="bi bi-folder" viewBox="0 0 16 16">
              <path d="M.54 3.87.5 3a2 2 0 0 1 2-2h3.672a2 2 0 0 1 1.414.586l.828.828A2 2 0 0 0 9.828 3h3.982a2 2 0 0 1 1.992 2.181l-.637 7A2 2 0 0 1 13.174 14H2.826a2 2 0 0 1-1.991-1.819l-.637-7a1.99 1.99 0 0 1 .342-1.31zM2.19 4a1 1 0 0 0-.996 1.09l.637 7a1 1 0 0 0 .995.91h10.348a1 1 0 0 0 .995-.91l.637-7A1 1 0 0 0 13.81 4H2.19zm4.69-1.707A1 1 0 0 0 6.172 2H2.5a1 1 0 0 0-1 .981l.006.139C1.72 3.042 1.95 3 2.19 3h5.396l-.707-.707z"/>
            </svg>
          </div>
          <div class="files_list__item__name">
            ../
          </div>
        </div>        
        <div class="files_list__item__commit col-md-6"">          
        </div>
        <div class="files_list__item__updated_at col-md-3">          
        </div>
      </div>

      <div class="files_list__item row" v-for="file in files" v-if="!loading && !editingFile" @click="fileClick(file)" :key="file.filename">
        <div class="col-md-3">
          <div class="files_list__item__icon">
            <svg v-if="file.type == 'blob'" xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" class="bi bi-file-earmark-code" viewBox="0 0 16 16">
              <path d="M14 4.5V14a2 2 0 0 1-2 2H4a2 2 0 0 1-2-2V2a2 2 0 0 1 2-2h5.5L14 4.5zm-3 0A1.5 1.5 0 0 1 9.5 3V1H4a1 1 0 0 0-1 1v12a1 1 0 0 0 1 1h8a1 1 0 0 0 1-1V4.5h-2z"/>
              <path d="M8.646 6.646a.5.5 0 0 1 .708 0l2 2a.5.5 0 0 1 0 .708l-2 2a.5.5 0 0 1-.708-.708L10.293 9 8.646 7.354a.5.5 0 0 1 0-.708zm-1.292 0a.5.5 0 0 0-.708 0l-2 2a.5.5 0 0 0 0 .708l2 2a.5.5 0 0 0 .708-.708L5.707 9l1.647-1.646a.5.5 0 0 0 0-.708z"/>
            </svg>
            <svg v-if="file.type == 'tree'" xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" class="bi bi-folder" viewBox="0 0 16 16">
              <path d="M.54 3.87.5 3a2 2 0 0 1 2-2h3.672a2 2 0 0 1 1.414.586l.828.828A2 2 0 0 0 9.828 3h3.982a2 2 0 0 1 1.992 2.181l-.637 7A2 2 0 0 1 13.174 14H2.826a2 2 0 0 1-1.991-1.819l-.637-7a1.99 1.99 0 0 1 .342-1.31zM2.19 4a1 1 0 0 0-.996 1.09l.637 7a1 1 0 0 0 .995.91h10.348a1 1 0 0 0 .995-.91l.637-7A1 1 0 0 0 13.81 4H2.19zm4.69-1.707A1 1 0 0 0 6.172 2H2.5a1 1 0 0 0-1 .981l.006.139C1.72 3.042 1.95 3 2.19 3h5.396l-.707-.707z"/>
            </svg>
          </div>
          <div class="files_list__item__name">
            {{ file.filename }}
          </div>
        </div>        
        <div class="files_list__item__commit col-md-6">
          <a v-if="fileInfo[directory + file.filename]" :href="`/project/${namespace}/${name}/commit/${fileInfo[directory + file.filename].hash}`">{{ fileInfo[directory + file.filename]? (fileInfo[directory + file.filename].author + ': ' + fileInfo[directory + file.filename].message) : '' }}</a>
        </div>
        <div class="files_list__item__updated_at col-md-3">
          {{ fileInfo[directory + file.filename]? fileInfo[directory + file.filename].author_date : '' }}
        </div>
      </div>

      <div class="" v-if="editingFile">
        <file-editor :name="name" :namespace="namespace" :filename="filename" :commit="fileCommit" :branch="branch"/>
      </div>
  </div>
</template>

<script>
  import FileEditor from './fileEditor.vue'

  export default {
    components: { FileEditor },
    props: [
      'name',
      'namespace',
    ],
    data () {
      return {
        files: [],
        branch: "master",
        loading: true,
        directory: "",
        fileInfo: {},
        editingFile: false,
        filename: null,
        fileCommit: null,
      }      
    },
    methods: {
      getFiles: function() {
        let self = this
        self.loading = true
        $.get(`/project/${self.namespace}/${self.name}/branch/${self.branch}/files${self.directory}`, function(data) {

          let directories = data.filter((a) => a.type == 'tree').sort((a, b) => a.filename > b.filename)
          let files = data.filter((a) => a.type != 'tree').sort((a, b) => a.filename > b.filename)
          self.files = directories.concat(files)
          self.loading = false

          self.files.forEach((file) => {
            self.getFileInfo(file.filename)
          })
        })  
      },
      getFileInfo: function(file, callback = null) {
        let self = this
        if (self.fileInfo[`${self.directory}${file}`]) {
          return;
        }

        $.get(`/project/${self.namespace}/${self.name}/branch/${self.branch}/file/log${self.directory}/${file}`, function(data) {
            self.fileInfo[`${self.directory}${file}`] = data[0]
            self.$forceUpdate();
            if (callback) {              
               self.$nextTick(() => {
                callback()
              })
            }
        }) 
      },
      fileClick: function(file) {
        if (file.type == 'tree') {
          return this.openDirectory(file)
        }
        this.filename = this.directory + '/' + file.filename
        this.fileCommit = this.fileInfo[`${this.directory}${file.filename}`]
        this.editingFile = true
        this.processHistoryState()
      },
      openDirectory: function(directory) {
        this.directory += '/' + directory.filename
        this.getFiles()
        this.processHistoryState()
      },
      parentDirectoryClick: function() {
        let parts = this.directory.split('/')
        parts.pop()
        this.directory = parts.join('/')
        this.getFiles()
        this.processHistoryState()
      },
      goToDirectory: function(index) {
        this.editingFile = false;
        this.filename = null
        this.fileCommit = null

        let parts = this.directory.split('/')
        while(parts.length != index + 1) {
          parts.pop()
        }
        this.directory = parts.join('/')
        this.getFiles()
        this.processHistoryState()
      },
      processHistoryState() {
        if (this.editingFile) {
          const state = {directory: this.directory, filename: this.filename, branch: this.branch}
          const title = `${this.namespace}/${this.name} ${this.filename}`
          const url = `/project/${this.namespace}/${this.name}/edit/${this.branch}${this.filename}`
          history.pushState(state, title, url)     

          return;
        }
        const state = {directory: this.directory, branch: this.branch}
        const title = `${this.namespace}/${this.name} ${this.directory}`
        const url = `/project/${this.namespace}/${this.name}/browse/${this.branch}${this.directory? this.directory : '/'}`
        history.pushState(state, title, url)   
      },
      loadFromUrlBrowse() {
        let parts = location.href.split(`/project/${this.namespace}/${this.name}/browse/`)
        if (parts.length < 2) {
          return;
        }
        let dataPart = parts[1]
        this.branch = dataPart.split('/')[0]
        this.directory = "/" + dataPart.replace(`${this.branch}/`, "")
        if (this.directory == "/") {
          this.directory = ""
        }
      },
      loadFromUrlEdit() {
        let parts = location.href.split(`/project/${this.namespace}/${this.name}/edit/`)
        if (parts.length < 2) {
          return;
        }
        let dataPart = parts[1]
        this.branch = dataPart.split('/')[0]        
        this.filename = "/" + dataPart.replace(`${this.branch}/`, "")
        let fileNameParts = this.filename.split('/')
        fileNameParts.pop()
        this.directory = fileNameParts.join('/')
        console.log(this.directory, this.filename)       
        this.getFileInfo(this.filename.replace(this.directory, ""), () => {
          this.fileCommit = this.fileInfo[this.filename]
          this.editingFile = true  
        })
      },
      loadFromUrl() {
        this.loadFromUrlBrowse()
        this.loadFromUrlEdit()
      }
    },
    mounted() {
      this.loadFromUrl();
      this.getFiles()
    },
    created() {
      let self = this
      eventBus.$on("branch_changed", (branch) => {
        self.branch = branch
        self.fileInfo = {}
        self.fileCommit = null
        self.getFiles()
        self.processHistoryState()        
      });
    }
  }
</script>
