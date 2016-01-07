#!-*- coding:utf-8 -*-
'''
Created on 2014-03-6

@author: francis

Usage:
  sudo yum install python python-devel gcc python-pip -y
  sudo pip install pyOpenSSL crypto
  sudo pip install pycrypto-on-pypi
  sudo pip install rsa
  sudo pip install pycrypto (Or: sudo easy_install pycrypto)

  `python yeepay_crypto.py crypto_data_file_name`
'''
import random, string
from Crypto import Random
from Crypto.Cipher import PKCS1_v1_5
from Crypto.Hash import SHA
from hashlib import sha1
from rsa import key, common, encrypt
from urllib import urlencode
# from yeepay import *
import base64
# import hmac
from Crypto.PublicKey import RSA
from Crypto.Cipher import AES
# import urllib
# import urllib2
import time, sys, os
import json, codecs
# import webbrowser
import pdb

from Crypto.Signature import PKCS1_v1_5 as pk

import tempfile

class MerchantAPI:
  def __init__(self, yeepay_public_key, merchant_private_key, merchant_public_key, merchantaccount):
      self.yeepay_public_key = yeepay_public_key
      self.merchant_private_key = merchant_private_key
      self.merchant_public_key = merchant_public_key
      self.merchantaccount = merchantaccount

  def doPost(self,url,values):
    '''
    post请求
    参数URL
    字典类型的参数
    '''
    req = urllib2.Request(url)
    data = urllib.urlencode(values)
    res = urllib2.urlopen(req, data)
    ret = res.read()
    return ret


  def doGet(self,url,values):
    '''
    get请求
    参数URL
    字典类型的参数
    '''
    REQUEST = url + "?" + urllib.urlencode(values)
    ret = urllib2.urlopen(REQUEST).read()
    return ret

  @staticmethod
  def _pkcs7padding(data):
    """
    对齐块
    size 16
    999999999=>9999999997777777
    """
    size = AES.block_size
    count = size - len(data)%size
    if count:
      data+=(chr(count)*count)

    return data

  @staticmethod
  def _random_key(length = 16):
    keys = string.lowercase+string.digits
    return ''.join(random.sample(keys, length))

  @staticmethod
  def _depkcs7padding(data):
    """
    反对齐
    """
    newdata = ''
    for c in data:
      if ord(c) > AES.block_size:
        newdata+=c
    return newdata


  '''
  aes加密base64编码
  '''
  def aes_base64_encrypt(self,data,key):

    """
    @summary:
      1. pkcs7padding
      2. aes encrypt
      3. base64 encrypt
    @return:
      string
    """
    cipher = AES.new(key)
    return base64.b64encode(cipher.encrypt(self._pkcs7padding(data)))


  def base64_aes_decrypt(self,data,key):
    """
    1. base64 decode
    2. aes decode
    3. dpkcs7padding
    """
    cipher = AES.new(key)

    return self._depkcs7padding(cipher.decrypt(base64.b64decode(data)))

  '''
  rsa加密
  '''
  def rsa_base64_encrypt(self,data,key):
    '''
    1. rsa encrypt
    2. base64 encrypt
    '''
    cipher = PKCS1_v1_5.new(key)
    return base64.b64encode(cipher.encrypt(data))

  def rsa_base64_decrypt(self,data,key):
    '''
    1. base64 decrypt
    2. rsa decrypt
    示例代码

     key = RSA.importKey(open('privkey.der').read())
    >>>
    >>> dsize = SHA.digest_size
    >>> sentinel = Random.new().read(15+dsize)    # Let's assume that average data length is 15
    >>>
    >>> cipher = PKCS1_v1_5.new(key)
    >>> message = cipher.decrypt(ciphertext, sentinel)
    >>>
    >>> digest = SHA.new(message[:-dsize]).digest()
    >>> if digest==message[-dsize:]:        # Note how we DO NOT look for the sentinel
    >>>   print "Encryption was correct."
    >>> else:
    >>>   print "Encryption was not correct."
    '''
    cipher = PKCS1_v1_5.new(key)
    return cipher.decrypt(base64.b64decode(data), Random.new().read(15+SHA.digest_size))

  '''
  RSA签名
  '''
  def sign(self,signdata):
    '''
    @param signdata: 需要签名的字符串
    '''

    h=SHA.new(signdata)
    signer = pk.new(self.merchant_private_key)
    signn=signer.sign(h)
    signn=base64.b64encode(signn)
    return  signn

  '''
  RSA验签
  结果：如果验签通过，则返回The signature is authentic
     如果验签不通过，则返回"The signature is not authentic."
  '''
  def checksign(self,rdata):
    signn=base64.b64decode(rdata.pop('sign'))
    signdata=self.sort(rdata)
    # print "signdata="+signdata

    verifier = pk.new(self.yeepay_public_key)
    if verifier.verify(SHA.new(signdata), signn):
      return True
    else:
      return False





  def sort(self,mes):
    '''
    作用类似与java的treemap,
    取出key值,按照字母排序后将value拼接起来
    返回字符串
    '''
    _par = []

    keys=mes.keys()
    keys.sort()

    # print str(keys.sort())
    for v in keys:
      _par.append(str(mes[v]))
    sep=  ''
    message=sep.join(_par)
    return message

  '''
  请求接口前的加密过程
  '''
  def data_encrypt(self,mesdata):
    '''
    加密过程：
    1、将需要的参数mes取出key排序后取出value拼成字符串signdata
    2、用商户私钥对signdata进行rsa签名，生成签名signn，并转base64格式
    3、将签名signn插入到mesdata的最后生成新的data
    4、用encryptkey16位常量对data进行AES加密后转BASE64,生成机密后的data
    5、用易宝公钥publickey对encryptkey16位常量进行RSA加密BASE64编码，生成encrypedencryptkey
    '''

    signdata=self.sort(mesdata)
    signn=self.sign(signdata)

    mesdata['sign']=signn
    mesdata_str = str(json.dumps(mesdata, ensure_ascii=False))

    encryptkey = self._random_key(16)#'1234567890123456'
    data=self.aes_base64_encrypt(mesdata_str,encryptkey)

    values={}
    values['merchantaccount']= self.merchantaccount
    values['data']=data
    values['sign']=signn
    values['encryptkey']=self.rsa_base64_encrypt(encryptkey,self.yeepay_public_key)
    return values


  '''
  对返回结果进行解密后输出
  '''
  def data_decrypt(self,result):
    '''
    1、返回的结果json传给data和encryptkey两部分，都为encryped
    2、用商户私钥对encryptkey进行RSA解密，生成decrypedencryptkey。参考方法：rsa_base64_decrypt
    3、用decrypedencryptkey对data进行AES解密。参考方法：base64_aes_decrypt
    '''
    kdata=result['data']
    kencryptkey=result['encryptkey']

    cryptkey=self.rsa_base64_decrypt(kencryptkey,self.merchant_private_key)
    # print 'decrypedencryptkey=  '+cryptkey
    rdata=json.loads(self.base64_aes_decrypt(kdata,cryptkey))

    if self.checksign(rdata):
      # print 'decrypeddata=  '+rdata
      return rdata
    else:
      return 'invaildate sign'

  '''
  网页收银台
  '''
  def testwap_credit(self):
    '''
    生成公钥私钥对过程：
    生成私钥：openssl genrsa -out rsa_private_key.pem 1024
    根据私钥生成公钥： openssl rsa -in rsa_private_key.pem -out rsa_public_key.pem -pubout
    这时候的私钥还不能直接被使用，需要进行PKCS#8编码：
    openssl pkcs8 -topk8 -in rsa_private_key.pem -out pkcs8_rsa_private_key.pem -nocrypt
    命令中指明了输入私钥文件为rsa_private_key.pem，输出私钥文件为pkcs8_rsa_private_key.pem，不采用任何二次加密（-nocrypt）
    加密过程：
    1、将需要的参数mes取出key排序后取出value拼成字符串signdata
    2、用signdata对商户私钥进行rsa签名，生成签名signn，并转base64格式
    3、将签名signn插入到mes的最后生成新的data
    4、用encryptkey16位常量对data进行AES加密后转BASE64,生成机密后的data
    5、用易宝公钥publickey对encryptkey16位常量进行RSA加密BASE64编码，生成encrypedencryptkey
    6、将merchantaccount，第四部encrypeddata，第五步encrypedencryptkey作为参数post请求给URL  http://ok.yeepay.com/payapi/api/bankcard/credit/pay/async
    7、返回的结果json传给data和encryptkey两部分，都为encryped
    8、用商户私钥对encryptkey进行RSA解密，生成decrypedencryptkey。参考方法：rsa_base64_decrypt
    9、用decrypedencryptkey对data进行AES解密。参考方法：base64_aes_decrypt
    '''
    transtime=int(time.time())
    od=str(random.randint(10, 100000))
    mesdata={
      "merchantaccount":'YB01000000144',
      "orderid":1394071333,
      "transtime":transtime,
      "currency":156,
      "amount":2,
      "productcatalog":"1",
      "userua":"你好",
      "productname":"",
      "productdesc":"",
      "userip":"192.168.5.251",
      "identityid":"identityid",
      "identitytype":6,
      "other":"",
      "callbackurl":'http://mobiletest.yeepay.com/apidemo/pay/callback',
      "fcallbackurl":'http://mobiletest.yeepay.com/apidemo/pay/callback'
    }
    values=self.data_encrypt(mesdata)
    #测试环境
    url=  'http://'+Gl.URL+'/paymobile/api/pay/request'
    #生产环境
    #url=  'http://'+Gl.URL+'/paymobile/api/pay/request'


    print url
    REQUEST = url + "?" + urllib.urlencode(values)
    print urllib.urlencode(values)
    webbrowser.open_new_tab(REQUEST)

  def testBindPayAsyncsign(self):
    '''
    绑卡支付
    RSA签名方式
    异步接口
    '''

    transtime=int(time.time())
    od=str(random.randint(10, 100000))
    mesdata={"merchantaccount":Gl.merchantaccount,'bindid':'940',"orderid":"33hhkssseef3u"+od,"transtime":transtime,"currency":156,"amount":2,"productcatalog":"1","productname":"小薇","productdesc":"","userip":"192.168.5.251","identityid":"ee","identitytype":6,"other":"","callbackurl":"http://172.18.66.20:9080/webtest/callback.do","fcallbackurl":"http://172.18.66.20:9080/webtest/callback.do"}
    values=self.data_encrypt(mesdata)
    #测试环境
    url=  'http://'+Gl.URL+'/testpayapi/api/bankcard/bind/pay/async'
    #生产环境
    #url=  'http://'+Gl.URL+'/payapi/api/bankcard/bind/pay/async'

    result=self.doPost(url, values)
    rdata=json.loads(self.data_decrypt(result))
    self.checksign(rdata)

  def destroy_temp_file(self,filename):
    os.unlink(f.name)
    os.path.exists(f.name)

def load_data(crypto_data_file_name):

  # just open the file...
  input_file  = file(crypto_data_file_name, "r")
  # need to use codecs for output to avoid error in json.dump
  output_file = codecs.open("output_file.json", "w", encoding="utf-8")

  # read the file and decode possible UTF-8 signature at the beginning
  # which can be the case in some files.
  j = json.loads(input_file.read().decode("utf-8-sig"))

  # then output it, indenting, sorting keys and ensuring representation as it was originally
  json.dump(j, output_file, indent=4, sort_keys=True, ensure_ascii=False)

# python yeepay_crypto.py /tmp/71d2c6e2a30c963020140306-27400-eirtmm
if __name__==  '__main__':
  reload(sys)
  sys.setdefaultencoding( "utf-8" )
  # publickey = RSA.importKey(open('rsa_public_key.pem','r').read())
  # privatekey = RSA.importKey(open('pkcs8_rsa_private_key.pem','r').read())
  crypto_data_file_name = sys.argv[1]

  if os.path.exists(crypto_data_file_name):
    crypto_data_file = open(crypto_data_file_name, "r")

    crypto_data_str = crypto_data_file.read().decode("utf-8-sig")
    # crypto_data_str = u'' + crypto_data_file.read()
    result = json.loads(crypto_data_str)
    # json.dumps(result, ensure_ascii = False)
    #
    #result = load_data(crypto_data_file_name)
    # newjson = json.dumps(result, ensure_ascii=False)

    merchant_private_key = RSA.importKey(result[u'merchant_private_key'])
    merchant_public_key = RSA.importKey(result[u'merchant_public_key'])
    yeepay_public_key = RSA.importKey(result[u'yeepay_public_key'])
    merchantaccount = result.get(u'merchantaccount')

    request_data = result.get(u'request_data')#.encode('utf8')
    response_data = result.get(u'response_data')#.encode('utf8')

    # MerchantAPI(yeepay_public_key, merchant_private_key, merchant_public_key, merchantaccount)
    mer = MerchantAPI(yeepay_public_key, merchant_private_key, merchant_public_key, merchantaccount)
    # mer.destroy_temp_file(crypto_data_file.name)

    if not type(request_data) == type(None):
      crypto_result = mer.data_encrypt(request_data)
    elif not type(response_data) == type(None):
      crypto_result = mer.data_decrypt(response_data)

    print json.dumps(crypto_result, ensure_ascii=False)
  else:
    print "no tempfile found"
