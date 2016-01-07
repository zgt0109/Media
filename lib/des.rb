# Base64,SHA1,MD5加密API调用

class Des
  ALG = 'DES-EDE3-CBC'
  # 定义不同的加密方法可以定义不同的key
  HEXED_DES_KEY = '9dd6ff77920b27db613e8607543109cca913f017f6a9140b'
  HEXED_DES_IV = '74e6b0b5da86175a'

  class << self
    # SHA1加密
    def sha1_encode(str)
      return Digest::SHA1.hexdigest(str)
    end

    # MD5加密
    def md5_encode(str)
      return Digest::MD5.hexdigest(str)
    end

    # 将des_encode和des_decode方法分别重命名为encrypt和decrypt方法。
    # 为了能够保存到数据库和Java程序也能解密，最后将加密后的结果进行了处理。
    # Java解密程序参见本文最后。
    def encrypt(str)
      cipher = OpenSSL::Cipher::Cipher.new(ALG)
      cipher.key = [HEXED_DES_KEY].pack('H*')
      cipher.iv =  [HEXED_DES_IV].pack('H*')
      cipher.encrypt
      str = "#{Time.now.strftime('%Y%m%d%H')}-#{str}"
      result = cipher.update(str) << cipher.final
      result.unpack('H*')[0]
    end

    def decrypt(str, validate_time: true)
      cipher = OpenSSL::Cipher::Cipher.new(ALG)
      cipher.key = [HEXED_DES_KEY].pack('H*')
      cipher.iv =  [HEXED_DES_IV].pack('H*')
      cipher.decrypt
      str = [str].pack('H*')
      date_hour, result = (cipher.update(str) + cipher.final).split('-', 2)
      time_valid = validate_time ? date_hour == Time.now.strftime('%Y%m%d%H') : true
      time_valid && result
    rescue
      false
    end
  end
end

# Java Des解密程序如下：
# import javax.crypto.Cipher;
# import javax.crypto.SecretKeyFactory;
# import javax.crypto.spec.*;
# import java.io.*;
# import java.security.Key;
# public class Des {
#     public static byte[] hexDecode(String hex) {
#         ByteArrayOutputStream bas = new ByteArrayOutputStream();
#         for (int i = 0; i < hex.length(); i+=2) {
#             int b = Integer.parseInt(hex.substring(i, i + 2), 16);
#             bas.write(b);
#         }
#         return bas.toByteArray();
#     }
#     public static String decrypt(String encryptedString) throws Exception {
#         byte[] key = hexDecode("9dd6ff77920b27db613e8607543109cca913f017f6a9140b");
#         byte[] iv = hexDecode("74e6b0b5da86175a");
#         DESedeKeySpec desKeySpec = new DESedeKeySpec(key);
#         SecretKeyFactory keyFactory = SecretKeyFactory.getInstance("DESede");
#         Key secretKey = keyFactory.generateSecret(desKeySpec);
#         IvParameterSpec ivSpec = new IvParameterSpec(iv);
#         Cipher cipher = Cipher.getInstance("DESede/CBC/PKCS5Padding");
#         cipher.init(Cipher.DECRYPT_MODE, secretKey, ivSpec);
#         byte [] buf = hexDecode(encryptedString);
#         cipher.update(buf, 0, buf.length);
#         return new String(cipher.doFinal());
#     }
#     public static void main(String[] args) throws Exception {
#         System.out.println(decrypt("98faa4f7f8131c40"));
#     }
# }
