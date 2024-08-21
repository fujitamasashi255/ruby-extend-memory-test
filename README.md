# README
### セットアップ
docker環境セットアップ・DBの作成後、 `bin/rails db:seed` で10万件のUserレコードが生成されます。

### rss計測
結果はlog/measure_rss に出力されます。

* extend ありで計測：
```
bin/rails measure_rss:with_extend
```

* extend なしで計測：
```
bin/rails measure_rss:without_extend
```

### heap-profiler で計測
結果はlog/memory_profile/find_each/with_extend_2024xxx/result.txt に出力されます。

* extend ありで計測：
```
bin/rails memory_profile:find_each:with_extend
```

* extend なしで計測：
```
bin/rails memory_profile:find_each:without_extend
```

[20240821_Shibuya.rb.pptx](https://github.com/user-attachments/files/16690075/20240821_Shibuya.rb.pptx)



