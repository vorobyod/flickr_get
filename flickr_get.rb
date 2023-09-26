#
# Simple utility to grab photos from group photostream
#

require 'flickraw'
require 'net/http'
require 'uri'

image_size = 'original'

FlickRaw.api_key = "--- Your Key Here ---"
FlickRaw.shared_secret = "--- Your Secret Here ---"

# Get group, first on is ours
groups = flickr.groups.search(:text => '--- Group name here ---')
group = groups[0]

# Get photos from group
i = 0
flickr.groups.pools.getPhotos(:group_id => group.nsid, :per_page => 200).each do |photo_rec|
    i += 1
    puts 'Downloading #' + i.to_s + ' - ' + photo_rec.title
    photo = nil
    flickr.photos.getSizes(:photo_id => photo_rec.id).each do |size_rec|
        if (size_rec.label =~ /#{image_size}/i)
            photo = size_rec
            break
        end
    end

    if photo
        # Got the photo! Now, get HTML and then extract
        # raw image URL
        image_url = nil

        url = URI.parse(photo.url)
        res = Net::HTTP.start(url.host, url.port) {|http|
            http.get(url.path)
        }
        html = res.body
        html =~ /<a href="(\S+)">\s*Download the #{image_size.capitalize} size of this photo/
        image_url = $1
        puts image_url
        `wget #{image_url}`
        
    else
        puts 'No ' + image_size + ' size photo for ' + photo_rec.id
    end
end

puts "Total #{i}"

