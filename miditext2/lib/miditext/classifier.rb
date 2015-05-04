
module Miditext

  class Classifier
    def classify(group)
      group.id
    end
  end

  class NoLengthClassifier
    def classify(group)
      group.id(:length => false)
    end
  end

end
