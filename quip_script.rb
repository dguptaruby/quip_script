require 'httparty'
require 'fileutils'

class Quip
  include HTTParty

  def fetchPrivateFolder(ids)
    ids.each do |id|
      response = HTTParty.get("https://platform.quip.com/1/folders/#{id}", headers: { Authorization: "Bearer #{@token}" })
      folder_title = response["folder"]["title"]
      if (Dir.mkdir "#{folder_title}") == 0
        puts "🗂 #{folder_title} created successfully"
      else
        puts "❌ Failed to create folder #{folderName}"
        return
      end
      response["children"].each_with_index do |children|
        fetchThreads(children, folder_title)
      end
    end
  end

  def fetchThreads(children, folder_title)
    response = HTTParty.get("https://platform.quip.com/1/threads/?ids=#{children['thread_id']}", headers: { Authorization: "Bearer #{@token}" })
    if FileUtils.touch("#{folder_title}/#{children['thread_id']}.html")
      puts "✅ #{children['thread_id']}.html file successfully created"
    else
      puts "❌ Failed to create file #{children['thread_id']}"
      return
    end
    if File.write("Friends/#{children['thread_id']}.html", response.parsed_response["#{children['thread_id']}"]["html"])
      puts "✅ #{children['thread_id']}.html saved successfully saved at local"
    else
      puts "❌ Failed to save file #{children['thread_id']} at local"
      return
    end
  end

  def fetch
    puts "Enter Authentication Token"
    @token = gets.chomp
    response = HTTParty.get("https://platform.quip.com/1/users/current", headers: { Authorization: "Bearer #{@token}" })
    response.parsed_response["shared_folder_ids"]
  end
end

quip = Quip.new
folder_ids = quip.fetch
quip.fetchPrivateFolder(folder_ids)
