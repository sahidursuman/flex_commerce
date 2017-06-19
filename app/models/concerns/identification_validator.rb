class IdentificationValidator < ActiveModel::Validator

  EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i

  def validate(record)
    if record.email.nil? && record.cell_number.nil?
      record.errors.add(:base,
        'An email address or a cell phoone number is required.')
    end
  end
end