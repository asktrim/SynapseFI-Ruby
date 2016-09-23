require 'test_helper'

class CipDocumentTest < Minitest::Test
  def setup
    @cip_doc = test_cip_document_with_documents
  end

  def test_initialize_params_can_be_read
    social_doc_info = {
      type: 'FACEBOOK',
      value: 'https://www.facebook.com/mariachi'
    }
    virtual_doc_info = {
      type: 'SSN',
      value: '2222'
    }
    physical_doc_info = {
      type: 'GOVT_ID',
      value: 'data:text/csv;base64,SUQs=='
    }
    social_doc   = SynapsePayRest::SocialDocument.new(social_doc_info)
    virtual_doc  = SynapsePayRest::VirtualDocument.new(virtual_doc_info)
    physical_doc = SynapsePayRest::PhysicalDocument.new(physical_doc_info)

    args = {
      user: test_user,
      email: 'piper@pie.com',
      phone_number: '4444444',
      ip: '127002',
      name: 'Piper',
      alias: 'Hallowell',
      entity_type: 'F',
      entity_scope: 'Arts & Entertainment',
      birth_day: 1,
      birth_month: 2,
      birth_year: 1933,
      address_street: '333 14th St',
      address_city: 'SF',
      address_subdivision: 'CA',
      address_postal_code: '94114',
      address_country_code: 'US',
      physical_documents: [physical_doc],
      social_documents: [social_doc],
      virtual_documents: [virtual_doc]
    }
    cip_doc = SynapsePayRest::CipDocument.create(args)

    args.each do |arg, value|
      assert_equal cip_doc.send(arg), value
    end
  end

  def test_initialize_with_documents_adds_them_to_documents_array
    social_doc_info = {
      type: 'FACEBOOK',
      value: 'https://www.facebook.com/mariachi'
    }
    virtual_doc_info = {
      type: 'SSN',
      value: '2222'
    }
    physical_doc_info = {
      type: 'GOVT_ID',
      value: 'data:text/csv;base64,SUQs=='
    }
    social_doc   = SynapsePayRest::SocialDocument.new(social_doc_info)
    virtual_doc  = SynapsePayRest::VirtualDocument.new(virtual_doc_info)
    physical_doc = SynapsePayRest::PhysicalDocument.new(physical_doc_info)

    cip_info = {
      user: test_user,
      email: 'piper@pie.com',
      phone_number: '4444444',
      ip: '127002',
      name: 'Piper',
      alias: 'Hallowell',
      entity_type: 'F',
      entity_scope: 'Arts & Entertainment',
      birth_day: 1,
      birth_month: 2,
      birth_year: 1933,
      address_street: '333 14th St',
      address_city: 'SF',
      address_subdivision: 'CA',
      address_postal_code: '94114',
      address_country_code: 'US',
      physical_documents: [physical_doc],
      social_documents: [social_doc],
      virtual_documents: [virtual_doc]
    }
    cip_doc = SynapsePayRest::CipDocument.create(cip_info)

    # verify docs associated with User object
    assert_equal cip_doc.physical_documents.length, 1
    assert_equal cip_doc.social_documents.length, 1
    assert_equal cip_doc.virtual_documents.length, 1
    assert_includes cip_doc.social_documents, social_doc
    assert_includes cip_doc.virtual_documents, virtual_doc
    assert_includes cip_doc.physical_documents, physical_doc
  end

  def test_submit
    social_doc_info = {
      type: 'FACEBOOK',
      value: 'https://www.facebook.com/mariachi'
    }
    virtual_doc_info = {
      type: 'SSN',
      value: '2222'
    }
    physical_doc_info = {
      type: 'GOVT_ID',
      value: 'data:text/csv;base64,SUQs=='
    }
    social_doc   = SynapsePayRest::SocialDocument.new(social_doc_info)
    virtual_doc  = SynapsePayRest::VirtualDocument.new(virtual_doc_info)
    physical_doc = SynapsePayRest::PhysicalDocument.new(physical_doc_info)

    cip_info = {
      user: test_user,
      email: 'piper@pie.com',
      phone_number: '4444444',
      ip: '127002',
      name: 'Piper',
      alias: 'Hallowell',
      entity_type: 'F',
      entity_scope: 'Arts & Entertainment',
      birth_day: 1,
      birth_month: 2,
      birth_year: 1933,
      address_street: '333 14th St',
      address_city: 'SF',
      address_subdivision: 'CA',
      address_postal_code: '94114',
      address_country_code: 'US',
      physical_documents: [physical_doc],
      social_documents: [social_doc],
      virtual_documents: [virtual_doc]
    }
    cip_doc = SynapsePayRest::CipDocument.create(cip_info)

    refute_nil cip_doc.id
    # verify with API that documents were added
    response_docs = test_client.users.get(user_id: cip_doc.user.id)['documents']
    assert [social_doc.cip_document.id, virtual_doc.cip_document.id, physical_doc.cip_document.id].all? do |id|
      id == response_docs['_id']
    end
    assert response_docs.first['social_docs'].any? { |doc| doc['document_type'] == social_doc.type }
    assert response_docs.first['virtual_docs'].any? { |doc| doc['document_type'] == virtual_doc.type }
    assert response_docs.first['physical_docs'].any? { |doc| doc['document_type'] == physical_doc.type }
  end

  def test_update
    user = test_user_with_cip_document_with_three_documents
    cip_doc = user.cip_documents.first
    social_doc = cip_doc.social_documents.find { |doc| doc.type == 'PHONE_NUMBER' }
    social_doc_original_value = social_doc.value
    original_email = cip_doc.email
    id_before = cip_doc.id

    response_before_update = test_client.users.get(user_id: user.id)
    response_before_update_phone_numbers = response_before_update['documents'].first['social_docs'].select do |doc|
      doc['document_type'] == 'PHONE_NUMBER'
    end

    # change value
    social_doc.value = '11111111'
    things_to_update = {
      email: 'judytrudy@boopy.com',
      social_documents: [social_doc]
    }

    cip_doc.update(things_to_update)
    new_email = cip_doc.email
    id_after = cip_doc.id

    # verify changed in instance
    refute_equal original_email, new_email
    refute_equal social_doc.value, social_doc_original_value

    # verify doc updated in API
    response_after_update = test_client.users.get(user_id: user.id)
    response_after_update_phone_numbers = response_after_update['documents'].first['social_docs'].select { |doc| doc['document_type'] == 'PHONE_NUMBER' }
    response_after_update_phone_number = response_after_update_phone_numbers.find { |ph| ph['id'] == social_doc.id }

    # id should match id in response
    assert_equal response_after_update['documents'].first['id'], cip_doc.id
    # see that updated times have changed
    before_checksum = response_before_update_phone_numbers.map {|ph| ph['last_updated']}.reduce(:+)
    after_checksum = response_after_update_phone_numbers.map {|ph| ph['last_updated']}.reduce(:+)
    assert_operator after_checksum, :>, before_checksum
    # verify status and id updated

    assert_equal response_after_update_phone_number['status'], social_doc.status

    # TODO: test last updated changes on virtual/physical docs
  end

  def test_add_document_to_cip_with_existing_docs
    skip 'pending'
  end

  def test_with_multiple_of_each_type_of_doc
    skip 'pending'
  end
end
