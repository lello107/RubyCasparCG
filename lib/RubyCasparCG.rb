require "RubyCasparCG/version"
require 'socket'
require 'nokogiri'
module RubyCasparCG
  class << self
   attr_accessor :timer2
  end
  @timer2 = {:home_t=>"JUV", :home_r=>1, :away_t=>"MIL", :away_r=>3, :set_timer_m=>0} 
  # Your code goes here...
  class Caspar
    @host="192.168.181.167"
    @port=5250
    @flash_layer=1
    @play_on_load=1
    def initialize(host,port)
       @host=host
       @port=port
       @flash_layer=10
       @play_on_load=1

       info()  
    end

    ##
    # connect to casparcg socket 
    # 
    # 
    def connect
      client = TCPSocket.new @host, @port
      return client
    end  

    ## print info
    #
    #
    def info
      puts "methods available:"
      puts " cmdFlashLoad(video_channel, layer, flash_layer, template,hash_data,and_play)"
      puts " cmdFlashInvoke(video_channel, layer, flash_layer,method_)"
      puts " cmdFlashUpdate(video_channel, layer, flash_layer,hash_data)"
      puts " cmdFlashPlay(video_channel, layer, flash_layer)"
      puts " cmdFlashClear(video_channel, layer)"
      puts " cmdFlashRemove(video_channel, layer)"
    end


    ##
    # generate formatted data for flash templates:
    # 
    # <templateData>
    #  <componentData id="f0">
    #    <data id="text" value="Niklas P Andersson" /> </componentData>
    #  <componentData id="f1">
    #    <data id="text" value="Developer" />
    #  </componentData>
    #  <componentData id="f2">
    #    <data id="text" value="Providing an example" />
    #  </componentData>
    # </templateData>
    # 
    def generateTemplateData(hash)
      str="<templateData>"
      hash.each do |k,v|
       str+= "<componentData id='#{k}'>"
       str+= "<data id='text' value='#{v}' />"
       str+= "</componentData>"
      end
      str+="</templateData>"#\""+" \r\n"
      return str
    end

    ## read socket non blocking
    #
    #
    def next_line_readable?(socket)
      readfds, writefds, exceptfds = select([socket], nil, nil, 0.1)
      #p :r => readfds, :w => writefds, :e => exceptfds
      readfds #Will be nil if next line cannot be read

    end

    ##
    # load and play flash template with hash parameteres
    # @channel = video_channel
    # @layer = layer
    # @template = template
    # @flash_layer = flash_layer
    # @hash_data = data 
    # @and_play = load and play play-on-load:0,1
    # 
    # exp. client.defFlashLoad(1,1,1,"TIMER2",hash_data: {home_t: "pino", set_timer_m: 90}, and_play: 1)
    def cmdFlashLoad(video_channel, layer, flash_layer, template, options = {})#cmdFlashLoad(video_channel, layer, flash_layer, template,hash_data,and_play)
        #defFlashLoad(video_channel, layer, flash_layer, template, options = {})
      video_channel ||= 1
      layer ||= 1
      flash_layer ||= @flash_layer
      template ||= ""
      hash_data = options[:hash_data] || {:r0=>"test"}
      and_play  = options[:and_play] || @and_play
      
      data = generateTemplateData(hash_data)
      puts "DATA: #{hash_data}"
      puts "GENERATED DATA: #{data}"
      puts "opening connection..."
      streamSock = TCPSocket.new( @host, @port ) 
      puts "connection opened!"
      streamSock_cmd = "CG #{video_channel}-#{layer} ADD #{flash_layer} #{template} #{and_play} \"#{data}\" \r\n"
      puts "SENDING: #{streamSock_cmd}"
      streamSock.puts(streamSock_cmd)
      results = streamSock.recv(1024)
      puts "RESPONSE: #{results}"
      streamSock.close
      puts "close connection ok!"
      
    end

    ##
    # Invoke label in flash template 
    # @channel = video_channel
    # @layer = layer
    # @flash_layer = flash_layer
    # @method_ = metto invokehod  
    # 
    # Calls a custom method in the document class of the template on the specified layer.
    # The method must return void and take no parameters.
    # Can be used to jump the playhead to a specific label.
    # 
    def cmdFlashInvoke(video_channel, layer, flash_layer,method_)

      video_channel ||= 1
      layer ||= 1
      flash_layer ||= @flash_layer

      puts "METHOD CALLED: #{method_}"
      puts "opening connection..."
      streamSock = TCPSocket.new( @host, @port ) 
      puts "connection opened!"
      streamSock_cmd = "CG #{video_channel}-#{layer} INVOKE #{flash_layer} #{method_} \r\n"
      puts "SENDING: #{streamSock_cmd}"
      streamSock.puts(streamSock_cmd)
      results = streamSock.recv(1024)
      puts "RESPONSE: #{results}"
      streamSock.close
      puts "close connection ok!"
      
    end



    ##
    # Update template prameters 
    # @channel = video_channel
    # @layer = layer
    # @flash_layer = flash_layer
    # @hash_data = data 
    # Sends new data to the template on specified layer. Data is either inline xml or a reference to a saved dataset
    # 
    def cmdFlashUpdate(video_channel, layer, flash_layer,hash_data)

      video_channel ||= 1
      layer ||= 1
      flash_layer ||= @flash_layer

      
      data = generateTemplateData(hash_data)
      puts "DATA: #{hash_data}"
      puts "GENERATED DATA: #{data}"
      puts "opening connection..."
      streamSock = TCPSocket.new( @host, @port ) 
      puts "connection opened!"
      streamSock_cmd = "CG #{video_channel}-#{layer} UPDATE #{flash_layer} \"#{data}\" \r\n"
      puts "SENDING: #{streamSock_cmd}"
      streamSock.puts(streamSock_cmd)
      results = streamSock.recv(1024)
      puts "RESPONSE: #{results}"
      streamSock.close
      puts "close connection ok!"
      
    end

    ##
    # play flash template with hash parameteres
    # @channel = video_channel
    # @layer = layer
    # @template = template
    # 
    # 
    def cmdFlashPlay(video_channel, layer, flash_layer)

      video_channel ||= 1
      layer ||= 1
      flash_layer ||= @flash_layer

      puts "opening connection..."
      streamSock = TCPSocket.new( @host, @port ) 
      puts "connection opened!"
      streamSock_cmd = "CG #{video_channel}-#{layer} PLAY #{flash_layer} \r\n"
      puts "SENDING: #{streamSock_cmd}"
      streamSock.puts(streamSock_cmd)
      results = streamSock.recv(1024)
      puts "RESPONSE: #{results}"
      streamSock.close
      puts "close connection ok!"
      
    end


    ##
    # Clears all layers and any state that might be stored.
    # What this actually does behind the scene is to create a new instance of the Adobe Flash player ActiveX controller 
    # in memory.
    # @channel = video_channel
    # @layer = layer
    # 
    # 
    def cmdFlashClear(video_channel, layer)

      video_channel ||= 1
      layer ||= 1

      puts "opening connection..."
      streamSock = TCPSocket.new( @host, @port ) 
      puts "connection opened!"
      streamSock_cmd = "CG #{video_channel}-#{layer} CLEAR \r\n"
      puts "SENDING: #{streamSock_cmd}"
      streamSock.puts(streamSock_cmd)
      results = streamSock.recv(1024)
      puts "RESPONSE: #{results}"
      streamSock.close
      puts "close connection ok!"
      
    end


    ##
    # Removes the visible template from a specific layer.
    # 
    # @channel = video_channel
    # @layer = layer
    # 
    # 
    def cmdFlashRemove(video_channel, layer,flash_layer)

      video_channel ||= 1
      layer ||= 1
      flash_layer ||= @flash_layer

      puts "opening connection..."
      streamSock = TCPSocket.new( @host, @port ) 
      puts "connection opened!"
      streamSock_cmd = "CG #{video_channel}-#{layer} REMOVE #{flash_layer} \r\n"
      puts "SENDING: #{streamSock_cmd}"
      streamSock.puts(streamSock_cmd)
      results = streamSock.recv(1024)
      puts "RESPONSE: #{results}"
      streamSock.close
      puts "close connection ok!"
      
    end



    ##
    # Stops and removes the template from the specified layer. 
    # This is different than REMOVE in that the template 
    # gets a chance to animate out when it is stopped.
    # 
    # @channel = video_channel
    # @layer = layer
    # @template = template
    # 
    # 
    def cmdFlashStop(video_channel, layer, flash_layer)

      video_channel ||= 1
      layer ||= 1
      flash_layer ||= @flash_layer

      puts "opening connection..."
      streamSock = TCPSocket.new( @host, @port ) 
      puts "connection opened!"
      streamSock_cmd = "CG #{video_channel}-#{layer} STOP #{flash_layer} \r\n"
      puts "SENDING: #{streamSock_cmd}"
      streamSock.puts(streamSock_cmd)
      results = streamSock.recv(1024)
      puts "RESPONSE: #{results}"
      streamSock.close
      puts "close connection ok!"
      
    end


    ##
    # Lists all media files in the media folder.
    # Use the command INFO PATHS to get the path to the media folder. 
    # 
    # 
    def cmdFlashInfo(template)


      puts "opening connection..."
      streamSock = TCPSocket.new( @host, @port ) 
      puts "connection opened!"
      streamSock_cmd = "INFO TEMPLATE #{template} \r\n"
      puts "SENDING: #{streamSock_cmd}"
      streamSock.puts(streamSock_cmd)

      data_buffer =[]

      while next_line_readable?(streamSock)
        data_buffer.push streamSock.gets.chop
      end

      streamSock.close
      puts "RESPONSE: #{data_buffer}"
      return data_buffer

      #arr_result=results.split("\r\n")
      #arr_result[]=Nokogiri::XML(arr_result[1])
      #puts "close connection ok!"
      #return arr_result
    end



    ##
    # Lists all media files in the media folder.
    # Use the command INFO PATHS to get the path to the media folder. 
    # 
    # 
    def cmdInfo(channel, layer)


      puts "opening connection..."
      streamSock = TCPSocket.new( @host, @port ) 
      puts "connection opened!"
      streamSock_cmd = "INFO #{channel}-#{layer} \r\n"
      puts "SENDING: #{streamSock_cmd}"
      streamSock.puts(streamSock_cmd)
      results = streamSock.recv(1024)
      puts "RESPONSE: #{results}"
      streamSock.close
      puts "close connection ok!"
      arr_result=results.split("\r\n")
      arr_result.map!{|x| x.gsub!("\"","")}
      return arr_result
    end





    ##
    # Lists all media files in the media folder.
    # Use the command INFO PATHS to get the path to the media folder. 
    # 
    # 
    def cmdTls()


      puts "opening connection..."
      streamSock = TCPSocket.new( @host, @port ) 
      puts "connection opened!"
      streamSock_cmd = "TLS \r\n"
      puts "SENDING: #{streamSock_cmd}"
      streamSock.puts(streamSock_cmd)
 
      data_buffer =[]

      while next_line_readable?(streamSock)
        data_buffer.push streamSock.gets.chop
      end

      return data_buffer

    end

    ##
    # Lists all media files in the media folder.
    # Use the command INFO PATHS to get the path to the media folder. 
    # 
    # 
    def cmdCls()


      puts "opening connection..."
      streamSock = TCPSocket.new( @host, @port ) 
      puts "connection opened!"
      streamSock_cmd = "CLS \r\n"
      puts "SENDING: #{streamSock_cmd}"
      streamSock.puts(streamSock_cmd)
      result=[]
      data_buffer =[]

      while next_line_readable?(streamSock)
        data_buffer.push streamSock.gets.chop
      end

      return data_buffer

    end

  end
end
