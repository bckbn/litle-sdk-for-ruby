=begin
Copyright (c) 2012 Litle & Co.

Permission is hereby granted, free of charge, to any person
obtaining a copy of this software and associated documentation
files (the "Software"), to deal in the Software without
restriction, including without limitation the rights to use,
copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following
conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.
=end
require 'lib/LitleOnline'
require 'test/unit'
require 'mocha'

#test Authorization Transaction
class TestAuth < Test::Unit::TestCase
  def test_success_re_auth
    hash = {
      'merchantId' => '101',
      'version'=>'8.8',
      'reportGroup'=>'Planets',
      'litleTxnId'=>'123456'
    }

    LitleXmlMapper.expects(:request).with(regexp_matches(/.*<litleTxnId>123456<\/litleTxnId>.*/m), is_a(Hash))
    LitleOnlineRequest.new.authorization(hash)
  end


  def test_both_choices_card_and_paypal
    hash = {
      'merchantId' => '101',
      'version'=>'8.8',
      'reportGroup'=>'Planets',
      'orderId'=>'12344',
      'amount'=>'106',
      'orderSource'=>'ecommerce',
      'card'=>{
      'type'=>'VI',
      'number' =>'4100000000000001',
      'expDate' =>'1210'
      },
      'paypal'=>{
      'payerId'=>'1234',
      'token'=>'1234',
      'transactionId'=>'123456'
      }}

    exception = assert_raise(RuntimeError){LitleOnlineRequest.new.authorization(hash)}
    assert_match /Entered an Invalid Amount of Choices for a Field, please only fill out one Choice!!!!/, exception.message
  end

  def test_three_choices_card_and_paypage_and_paypal
    hash = {
      'merchantId' => '101',
      'version'=>'8.8',
      'reportGroup'=>'Planets',
      'orderId'=>'12344',
      'amount'=>'106',
      'orderSource'=>'ecommerce',
      'card'=>{
      'type'=>'VI',
      'number' =>'4100000000000001',
      'expDate' =>'1210'
      },
      'paypage'=> {
      'paypageRegistrationId'=>'1234',
      'expDate'=>'1210',
      'cardValidationNum'=>'555',
      'type'=>'VI'},
      'paypal'=>{
      'payerId'=>'1234',
      'token'=>'1234',
      'transactionId'=>'123456'
      }}
    exception = assert_raise(RuntimeError){LitleOnlineRequest.new.authorization(hash)}
    assert_match /Entered an Invalid Amount of Choices for a Field, please only fill out one Choice!!!!/, exception.message
  end

  def test_all_choices_card_and_paypage_and_paypal_and_token
    hash = {
      'merchantId' => '101',
      'version'=>'8.8',
      'reportGroup'=>'Planets',
      #      'litleTxnId'=>'123456',
      'orderId'=>'12344',
      'amount'=>'106',
      'orderSource'=>'ecommerce',
      'fraudCheck'=>{'authenticationTransactionId'=>'123'},
      'bypassVelocityCheckcardholderAuthentication'=>{'authenticationTransactionId'=>'123'},
      'card'=>{
      'type'=>'VI',
      'number' =>'4100000000000001',
      'expDate' =>'1210'
      },
      'paypage'=> {
      'paypageRegistrationId'=>'1234',
      'expDate'=>'1210',
      'cardValidationNum'=>'555',
      'type'=>'VI'},
      'paypal'=>{
      'payerId'=>'1234',
      'token'=>'1234',
      'transactionId'=>'123456'},
      'token'=> {
      'litleToken'=>'1234',
      'expDate'=>'1210',
      'cardValidationNum'=>'555',
      'type'=>'VI'
      }}

    exception = assert_raise(RuntimeError){LitleOnlineRequest.new.authorization(hash)}
    assert_match /Entered an Invalid Amount of Choices for a Field, please only fill out one Choice!!!!/, exception.message
  end

  def test_merchant_data_auth
    hash = {
      'merchantId' => '101',
      'version'=>'8.12',
      'orderId'=>'1',
      'amount'=>'0',
      'orderSource'=>'ecommerce',
      'reportGroup'=>'Planets',
      'merchantData'=> {
        'campaign'=>'foo'
      }
    }
  
    XMLObject.expects(:new)
    Communications.expects(:http_post).with(regexp_matches(/.*<merchantData>.*?<campaign>foo<\/campaign>.*?<\/merchantData>.*/m),kind_of(Hash))
    LitleOnlineRequest.new.authorization(hash)
  end
  
end

