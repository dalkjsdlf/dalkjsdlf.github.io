---
title: "개인적인 글"
layout: archive
permalink: categories/personal
author_profile: true
sidebar_main: true
---

{% assign posts = site.categories.Personal %}
{% for post in posts %} {% include archive-single.html type=page.entries_layout %} {% endfor %}