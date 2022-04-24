PARTS_OF_SPEECH = ['v', 'n', 'adj', 'adv', 'prep']
ENGLISH_LEVEL = ['B2', 'C1']


class LoadDictionary < ApplicationJob

  def perform(link_to_file, doc_id)
    @counter = 0
    @doc_id = doc_id

    # open file
    file = URI.open(link_to_file)

    parse_pdf(file: file)
  end

  private

  def parse_pdf(file: )
    pdf_file = PDF::Reader.new(file)
    # puts pdf_file.pdf_version
    # puts pdf_file.info
    # puts pdf_file.metadata
    # puts pdf_file.page_count

    pdf_file.pages.each do |page|
      parse_text(page: page.text)
    end
  end

  def translate(word: )
    File.delete('./telegram/buffer.json') if File.exist?('./telegram/buffer.json')

    runner = NodeRunner.new(
      <<~JAVASCRIPT
    const Reverso = require('/Users/andreykuluev/node_modules/reverso-api/index.js');
    const reverso = new Reverso();
    
    function reverso_translate(word, language) {
      return reverso.getContext(word, 'English', language, (response) => {
        var fs = require('fs');
        fs.writeFileSync("./telegram/buffer.json", JSON.stringify(response), function(err) {
          if (err) {
              // console.log(err);
          }
        });
      }).catch((err) => {
          // console.log(err);
      });
    }
    JAVASCRIPT
    )

    runner.reverso_translate(word, "Russian")
    if File.exists?("./telegram/buffer.json")
      file = File.read("./telegram/buffer.json")
      responce = JSON.parse(file)
      File.delete('./telegram/buffer.json') if File.exist?("./telegram/buffer.json")

      return responce
    else
      return nil
    end
  end

  def parse_text(page: )
    words = page.split(/\W+/)

    @parts_of_speech = []
    @word = ""
    @level = []

    words.each_with_index do |val,index|
      if(val == 'v' || val == 'n' || val == 'adj' || val == 'adv' || val == 'prep' || val == 'C1' || val == 'B2')
        if(val == 'v' || val == 'n' || val == 'adj' || val == 'adv' || val == 'prep')
          if @word.empty?
            @word = words[index-1]
          end

          @parts_of_speech.push val
        end

        if(val == 'C1' || val == 'B2')
          if @word.empty?
            @word = words[index-1]
          end

          @level.push val
        end
      else
        unless @word.empty?
          @counter += 1

          if(!Dictionary.exists?(word: @word))
            transl_res = translate(word: @word)
            while transl_res.nil?
              transl_res = translate(word: @word)
            end

            if transl_res['text'] == @word
              res = "#{@counter}: word: #{@word}, parts_of_speech: #{@parts_of_speech}, level: #{@level}, translate: #{transl_res['translation'].first}"
              puts res

              Dictionary.create(word: @word, translation: transl_res['translation'].join(','), level: @level.join(','), parts_of_speech: @parts_of_speech.join(','), examples: transl_res['examples'].to_json)
            else
              p "skipped word! #{@word}"
            end
          end

          DocumentDictionary.create(dictionary_id: Dictionary.find_by(word: @word).id, document_id: @doc_id)

          @parts_of_speech  = []
          @word = ""
          @level = []
        end
      end
    end
  end
end
