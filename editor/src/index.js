import registerApi from './api'
import Editor from './editor'

registerApi({ editor: new Editor() })
