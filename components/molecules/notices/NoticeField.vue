<template>
  <div>
    <v-badge
    color="primary"
    :value="nonChecked"
    :content="nonChecked"
    overlap
    >
      <v-icon
      @click="openField"
      style="color: white"
      >
      far fa-bell
      </v-icon>
    </v-badge>
    </IconButton>
    <v-card v-if="noticeField" id="notice-field">
      <v-card-title id="notice-field-title">
        <span>通知</span>
        <v-spacer />
        <span @click="closeField">
          <nuxt-link
          to="/notices"
          id="to-notices"
          >通知一覧</nuxt-link>
        </span>
      </v-card-title>
      <v-card-text>
        <Notice
        v-for='notice in notices'
        :key="notice.id"
        :notice="notice"
        @closeField="closeField"
        />
        <span v-if="!notices.length">通知はありません。</span>
      </v-card-text>
    </v-card>
  </div>
</template>

<script>
import Notice from './Notice.vue'
import axios from '@/plugins/axios'
export default {
  components: {
    Notice
  },
  data () {
    return {
      noticeField: false,
      notices: []
    }
  },
  computed: {
    currentUser () {
      return this.$store.state.currentUser
    },
    nonChecked () {
      const nonChecked = this.notices.filter((n) => {
        return !n.checked
      })
      return nonChecked.length
    }
  },
  methods: {
    openField () {
      if (this.noticeField) {
        this.$store.commit('drawing/setOverlay', false)
        return
      }
      this.noticeField = true
      this.$store.commit('drawing/setOverlay', true)
      if (this.nonChecked) {
        axios
          .get(`/v1/users/${this.currentUser.id}/notices/check`)
          .then((res) => {
            this.notices = res.data
          })
      }
    },
    closeField () {
      this.$store.commit('drawing/setOverlay', false)
    }
  },
  mounted () {
    this.$store.subscribe((mutation, state) => {
      if (mutation.type === 'drawing/setOverlay') {
        if (!mutation.payload) { this.noticeField = false }
      }
    })
    const that = this
    const getNotice = function () {
      if (that.currentUser) {
        axios
          .get(`/v1/users/${that.currentUser.id}/notices`, {
            params: {
              limit: true
            }
          })
          .then((res) => {
            that.notices = res.data
          })
      }
    }
    setTimeout(getNotice, 3000)
    setInterval(getNotice, 60000)
  }
}
</script>

<style scoped>
#notice-field-title {
  padding-top: 0px;
  font-size: 1.0em;
}

#notice-field {
  display: block;
  position: absolute;
  right: 400px;
  z-index: 1000;
  width: 320px;
  height: 480px;
  background-color: #fff;
  padding: 16px 0;
  border: 1px solid #ddd;
  border-radius: 3px;
  box-shadow: 0 0 8px 0 rgba(0,0,0,0.15);
  overflow-y: scroll;
}

#to-notices {
  color: inherit;
  text-decoration: none;
  font-size: 0.8em;
}

@media (max-width: 1024px) {
  #notice-field {
    top: 45px;
    right: 300px;
  }
}

@media (max-width: 480px) {
  #notice-field {
    top: 45px;
    right: 30px;
    width: 320px;
    height: 480px;
  }
}
</style>
