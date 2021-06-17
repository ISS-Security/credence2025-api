# frozen_string_literal: true

require 'rbnacl'
require 'base64'

# Verifies digitally signed requests
class SignedRequest
  class VerificationError < StandardError; end
  class KeypairError < StandardError; end

  def self.setup(verify_key64, signing_key64)
    @verify_key = Base64.strict_decode64(verify_key64)
    @signing_key = Base64.strict_decode64(signing_key64)
  rescue StandardError
    raise KeypairError, 'Invalid verification/signing keypair'
  end

  def self.generate_keypair
    signing_key = RbNaCl::SigningKey.generate
    verify_key = signing_key.verify_key

    { signing_key: Base64.strict_encode64(signing_key),
      verify_key: Base64.strict_encode64(verify_key) }
  end

  def self.parse(signed)
    signed[:data] if verify(signed[:data], signed[:signature])
  end

  # Signing for internal tests (should be same as client method)
  def self.sign(message)
    signature = RbNaCl::SigningKey.new(@signing_key)
      .sign(message.to_json)
      .then { |sig| Base64.strict_encode64(sig) }

    { data: message, signature: signature }
  end

  def self.verify(message, signature64)
    signature = Base64.strict_decode64(signature64)
    verifier = RbNaCl::VerifyKey.new(@verify_key)
    verifier.verify(signature, message.to_json)
  rescue StandardError
    raise VerificationError
  end
end
