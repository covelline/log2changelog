
module Log2changelog
  class Parser

    def initialize(types)
      @types = types
    end

    def parse(string)

      logs = string.split("\n").flat_map { |line|
        m = line.match(/^\[(.+?)\](?:\[(.+?)\])? (.+)$/)
        if m
          (type, scope, msg) = m.captures
          [{type: type, scope: scope, msg:msg}]
        else
          []
        end
      }.group_by { |item|
        item[:type]
      }.map { |item|

        {type: item[0], scopes: item[1].map { |s|
          s.delete(:type)
          s
        }}

      }.map { |item|

        item.merge(scopes: item[:scopes].group_by{ |l|
          l[:scope]
        }.map {|l|
          {scope: l[0],
           msgs: l[1].map { |s|
            s.delete(:scope)
            s[:msg]
          }}
        })
      }

      @types.map{|t|
        type = logs.find {|l| l[:type] == t}
        if type
           mkChangelog(type)
        end
      }.join("\n")

    end

    private

    def mkChangelog(type)

      scopesMessages = (type[:scopes].map{|s| mkScopeMessages(s, "---")}).join("\n")
      <<EOS
# #{type[:type]}

#{scopesMessages}
EOS
    end

    def mkScopeMessages(scope, emptyScope = "")
      msgs = scope[:msgs].map{|m| mkMessage(m)}.join("\n")
      <<EOS
## #{scope[:scope] ? scope[:scope] : emptyScope}

#{msgs}
EOS
    end

    def mkMessage(msg)
      %[- #{msg}]
    end

  end
end
