package org.postgresql.febe.message {

    import org.postgresql.febe.message.AbstractMessage;
    import org.postgresql.febe.message.IBEMessage;
    import org.postgresql.febe.message.MessageError;
    import org.postgresql.io.ICDataInput;

    public class CommandComplete extends AbstractMessage implements IBEMessage {

        public var commandTag:String;
        public var command:String;
        public var oid:int;
        public var affectedRows:int;

        private static const INSERT_CMD:RegExp = /INSERT (\d+) (\d+)/;
        private static const COPY_CMD:RegExp = /COPY (\d+)?/;
        private static const OTHER_ROW_CMD:RegExp = /(DELETE|UPDATE|MOVE|FETCH) (\d+)/;

        public function CommandComplete() {
            oid = -1;
            affectedRows = 0;
        }

        public function read(input:ICDataInput):void {
            commandTag = input.readCString();
            var match:Array;
            if (INSERT_CMD.test(commandTag)) {
                match = commandTag.match(INSERT_CMD);
                if (match.length != 3) {
                     badTag(commandTag);
                }
                command = 'INSERT';
                oid = match[1];
                affectedRows = match[2];
            } else if (OTHER_ROW_CMD.test(commandTag)) {
                match = commandTag.match(OTHER_ROW_CMD);
                if (match.length != 3) {
                     badTag(commandTag);
                }
                command = match[1];
                affectedRows = match[2];
            } else if (COPY_CMD.test(commandTag)) {
                match = commandTag.match(COPY_CMD);
                if (match.length < 2) {
                     badTag(commandTag);
                }
                command = 'COPY';
                affectedRows = match.length > 1 ? match.length[1] : -1;
            } else {
                command = commandTag;
            }
        }

        private function badTag(tag:String):void {
            throw new MessageError("Unexpected command tag: " + tag, this);
        }

        override public function toString():String {
            return super.toString() + ' {' + commandTag + '}';
        }

    }
}