# extablish connection with ActionCable server and set callback on receive event

import Vue from 'vue/dist/vue.esm'

ActionCable = require('actioncable')
cable = ActionCable.createConsumer()
newsTableVue = undefined

cable.subscriptions.create "NewsChannel",
  received: (data) ->
    if newsTableVue
      newsTableVue.update_news data.news
    else
      newsTableVue = new Vue(
        el: '#current-news-block'
        data:
          pub_date: data.news.pub_date
          title: data.news.title
          description: data.news.description
        methods:
          update_news: (fresh_news) ->
            @pub_date = fresh_news.pub_date
            @title = fresh_news.title
            @description = fresh_news.description)
