module OpenNLP::Bindings

  # Require configuration.
  require 'open-nlp/config'

  # ############################ #
  # BindIt Configuration Options #
  # ############################ #

  require 'bind-it'
  extend BindIt::Binding

  # Load the JVM with a minimum heap size of 512MB,
  # and a maximum heap size of 1024MB.
  self.jvm_args = ['-Xms512M', '-Xmx1024M']

  # Turn logging off by default.
  self.log_file = nil

  # Default JARs to load.
  self.default_jars = [
    'jwnl-1.3.3.jar',
    'opennlp-tools-1.5.3-incubating.jar',
    'opennlp-maxent-3.0.3-incubating.jar',
    'opennlp-uima-1.5.3-incubating.jar'
  ]

  # Default namespace.
  self.default_namespace = 'opennlp.tools'

  # Default classes.
  self.default_classes = [
    # OpenNLP classes.
    ['AbstractBottomUpParser', 'opennlp.tools.parser'],
    ['DocumentCategorizerME', 'opennlp.tools.doccat'],
    ['ChunkerME', 'opennlp.tools.chunker'],
    ['DictionaryDetokenizer', 'opennlp.tools.tokenize'],
    ['NameFinderME', 'opennlp.tools.namefind'],
    ['Parser', 'opennlp.tools.parser.chunking'],
    ['Parse', 'opennlp.tools.parser'],
    ['ParserFactory', 'opennlp.tools.parser'],
    ['POSTaggerME', 'opennlp.tools.postag'],
    ['SentenceDetectorME', 'opennlp.tools.sentdetect'],
    ['SimpleTokenizer', 'opennlp.tools.tokenize'],
    ['Span', 'opennlp.tools.util'],
    ['TokenizerME', 'opennlp.tools.tokenize'],
    
    # Generic Java classes.
    ['FileInputStream', 'java.io'],
    ['String', 'java.lang'],
    ['ArrayList', 'java.util']
  ]
  
  # Add in Rjb workarounds.
  unless RUBY_PLATFORM =~ /java/
    self.default_jars << 'utils.jar'
    self.default_classes << ['Utils', '']
  end

  # ############################ #
  #   OpenNLP bindings proper    #
  # ############################ #

  class <<self
    # A hash containing loaded models.
    attr_accessor :models
    # A hash containing the names of loaded models.
    attr_accessor :model_files
    # The folder in which to look for models.
    attr_accessor :model_path
    # Store the language currently being used.
    attr_accessor :language
  end

  def self.default_path
    File.dirname(__FILE__) + '/../../bin/'
  end

  # The loaded models.
  self.models = {}

  # The names of loaded models.
  self.model_files = {}

  # The path in which to look for JAR files, with
  # a trailing slash (default is gem's bin folder).
  self.jar_path = self.default_path

  # The path to the main folder containing the folders
  # with the individual models inside. By default, this
  # is the same as the JAR path.
  self.model_path = self.jar_path

  # Default the language to English.
  self.language = :english

  # Use a given language for default models.
  def self.use(language)
    self.language = language
  end

  def self.get_model(klass, file=nil)
    name = OpenNLP::Config::ClassToName[klass]
    if !self.language and !file
      raise 'No model file was supplied to the ' +
      'constructor. Please supply a model file ' +
      'or call OpenNLP.use(:some_language), to ' +
      'load the default models for a language.'
    end
    self.load_model(name, file)
    model = self.models[name]
  end

  def self.set_model
    raise 'Not implemented.'
  end

  def self.load_model(name, file = nil)
    if self.models[name] && file ==
      self.model_files[name]
      return self.models[name]
    end
    models = OpenNLP::Config::DefaultModels[name]
    file ||= models[self.language]
    path = self.model_path + file
    stream = FileInputStream.new(path)
    klass = OpenNLP::Config::NameToClass[name]
    load_class(*klass) unless const_defined?(klass[0])
    klass = const_get(klass[0])
    model = klass.new(stream)
    self.model_files[name] = file
    self.models[name] = model
  end

end
