package com.github.sonarperl.lexer;

import com.sonar.sslr.api.GenericTokenType;
import com.sonar.sslr.api.Token;
import com.sonar.sslr.impl.Lexer;
import org.sonar.sslr.channel.Channel;
import org.sonar.sslr.channel.CodeReader;

import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class PODChannel extends Channel<Lexer> {

    private static final char EOF = (char) -1;

    private StringBuilder sb;

    private static final Matcher POD_START = Pattern.compile("=pod").matcher("");
    private static final Matcher POD_END = Pattern.compile("[\\n\\r]=cut").matcher("");

    @Override
    public boolean consume(CodeReader code, Lexer output) {
        int line = code.getLinePosition();
        int column = code.getColumnPosition();
        sb = new StringBuilder();
        if (column == 0 && code.popTo(POD_START, sb) > 0) {
            // TODO: should be newline + =cut
           String pod = consumePod(code);
           // POD token
           output.addToken(Token.builder()
                .setLine(line)
                .setColumn(column)
                .setURI(output.getURI())
                .setType(GenericTokenType.COMMENT)
                .setValueAndOriginalValue(pod)
                .setGeneratedCode(true)
                .build());
            return true;
        }
        return false;
    }

    private String consumePod(CodeReader code) {
       while (code.length() > 0 && !POD_END.reset(sb.substring(Math.max(0, sb.length()-5), sb.length())).matches()) {
           code.pop(sb);
       }
       return sb.toString();
    }

}
