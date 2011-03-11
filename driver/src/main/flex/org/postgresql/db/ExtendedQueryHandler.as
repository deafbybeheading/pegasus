package org.postgresql.db {
    import org.postgresql.Oid;
    import org.postgresql.febe.ArgumentInfo;
    import org.postgresql.EncodingFormat;
    import org.postgresql.io.ByteDataStream;
    import org.postgresql.codec.IPGTypeEncoder;
    import org.postgresql.util.getType;
    import org.postgresql.febe.IExtendedQueryHandler;
    import org.postgresql.codec.CodecFactory;

    public class ExtendedQueryHandler extends SimpleQueryHandler implements IExtendedQueryHandler {

        public function ExtendedQueryHandler(resultHandler:IResultHandler, codecs:CodecFactory) {
            super(resultHandler, codecs);
        }

        public function describeArguments(params:Array, serverParams:Object):Array {
            var encodedArgs:Array = [];
            for (var arg:Object in params) {
                var argInfo:ArgumentInfo;
                if (arg == null) {
                    argInfo = new ArgumentInfo(EncodingFormat.TEXT, Oid.UNSPECIFIED, null);
                } else {
                    var argType:Class = getType(arg);
                    var argEncoder:IPGTypeEncoder = _codecFactory.getEncoder(argType);
                    var argOid:int = argEncoder.getInputOid(argType);
                    var encodedValue:ByteDataStream = new ByteDataStream();

                    argEncoder.encode(encodedValue, arg, EncodingFormat.TEXT, serverParams);
                    argInfo = new ArgumentInfo(EncodingFormat.TEXT, argOid, encodedValue);
                }
                encodedArgs.push(argInfo);
            }
            return encodedArgs;
        }

        public function getOutputFormats(fieldDescriptions:Array):Array {
            return [ EncodingFormat.TEXT ];
        }
    }
}
