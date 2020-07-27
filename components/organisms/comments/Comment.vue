<template>
  <v-container>
    <v-card class="mx-auto mt-5 pa-5" width="600px">
      <v-card-title>
        <v-avatar size="40">
          <img v-if="comment.user.avatar_url" :src="comment.user.avatar_url" />
          <img v-else src="~/assets/default_icon.jpeg" />
        </v-avatar>
        <nuxt-link :to="toUserLink" class="no-link-style">
          <span style="margin-left: 15px;">
            {{ comment.user.name }}
          </span>
          <small style="color: #BDBDBD; margin-left: 10px">
            @{{ comment.user.screen_name }}
          </small>
        </nuxt-link>
        <v-spacer />
        <IconButtonWithAuth
        type="far fa-trash-alt"
        :comparison="comment.user_id"
        style="margin-right: 10px;"
        @click="deleteComment"
        small
        />
      </v-card-title>
      <v-card-text>
        <v-row>
          {{ comment.content }}
        </v-row>
        <v-row>
          <v-spacer />
          <LikeButton
          :objectId="comment.id"
          objectType="Comment"
          :likesCount="comment.likes_count"
          @destroyLike="subCount"
          @addLiked="addCount"
          />
        </v-row>
      </v-card-text>
    </v-card>
  </v-container>
</template>

<script>
import LikeButton from '../../molecules/LikeButton.vue'
import axios from '@/plugins/axios'
export default {
  components: {
    LikeButton
  },
  props: {
    comment: {
      type: Object,
      required: true
    }
  },
  computed: {
    currentUser () {
      return this.$store.state.currentUser
    },
    toUserLink () {
      return `/users/${this.comment.user.id}`
    }
  },
  methods: {
    deleteComment () {
      const confirm = window.confirm('削除しますか？') // eslint-disable-line
      if (confirm) {
        const commentId = this.comment.id
        axios
          .delete(`/v1/comments/${commentId}`)
          .then((res) => {
            this.$emit('deleteComment', commentId)
            this.$store.commit('drawing/setFlash', {
              status: true,
              type: 'success',
              message: 'コメントを削除しました'
            })
            setTimeout(() => {
              this.$store.commit('drawing/setFlash', {})
            }, 2000)
          })
      }
    },
    subCount () {
      this.$emit('subCommentLikesCount', this.comment.id)
    },
    addCount () {
      this.$emit('addCommentLikesCount', this.comment.id)
    }
  }
}
</script>

<style scoped>
.no-link-style {
  color: inherit;
  text-decoration: none;
}
</style>