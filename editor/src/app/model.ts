import { FileActionOptions, FileLoadOptions } from '../api/api-interface'
import Editor, { SeabassEditorState } from '../editor/editor'

export interface EditorStateChangeOptions extends SeabassEditorState {
  /** full path to file */
  filePath: string
}

/** Colors matching platform-specific app's theme */
export interface SeabassHtmlTheme {
  /** Background color */
  backgroundColor: string
  /** Highlighted elements color */
  highlightColor: string
  /** Basic text color */
  textColor: string
}

export interface SeabassCommonPreferences {
  /** Required to set metching editor theme */
  isDarkTheme: boolean
  /** HTML page's offset from the bottom of webView. Used as a workaround to SfOS rendering issues */
  verticalHtmlOffset: number
}

export interface SeabassSailfishPreferences {
  /** Bottom toolbar state */
  isToolbarOpened: boolean
}

export type InputPreferences = SeabassHtmlTheme & Partial<SeabassCommonPreferences>

interface AppEvents {
  htmlThemeChange: CustomEvent<SeabassHtmlTheme>
  closeFile: CustomEvent<FileActionOptions>
  loadFile: CustomEvent<FileLoadOptions>
  log: CustomEvent<unknown>
  preferencesChange: CustomEvent<SeabassCommonPreferences>
  sfosPreferencesChange: CustomEvent<SeabassSailfishPreferences>
  stateChange: CustomEvent<EditorStateChangeOptions>
}

type AppEventListener<T extends keyof AppEvents> = ((evt: AppEvents[T]) => void) |
({ handleEvent: (evt: AppEvents[T]) => void }) | null

export default class SeabassAppModel extends EventTarget {
  _editors: Map<string, Editor>

  /** Welcome note theme */
  _htmlTheme?: {
    backgroundColor: string
    textColor: string
    highlightColor: string
  }

  /** App preferences */
  _preferences: {
    isDarkTheme: boolean
    verticalHtmlOffset: number
  }

  /** SailfishOS-specific preferences */
  _sailfish: {
    isToolbarOpened: boolean
  }

  SFOS_TOOLBAR_LOCAL_STORAGE_KEY = 'sailfish__isToolbarOpened'

  constructor () {
    super()
    this._editors = new Map()
    this._preferences = {
      isDarkTheme: false,
      verticalHtmlOffset: 0
    }
    this._sailfish = {
      isToolbarOpened: localStorage.getItem(this.SFOS_TOOLBAR_LOCAL_STORAGE_KEY) === 'true'
    }
  }

  get sailfishPreferences (): SeabassSailfishPreferences {
    return this._sailfish
  }

  addEventListener<T extends keyof AppEvents>(type: T,
    callback: AppEventListener<T>, options?: EventListenerOptions): void {
    super.addEventListener(type, callback as EventListenerOrEventListenerObject | null, options)
  }

  dispatchEvent<T extends keyof AppEvents>(event: AppEvents[T]): boolean {
    return super.dispatchEvent(event)
  }

  /**
   * Closes opened file
   * @param filePath full path to file
   */
  closeFile (filePath: string): void {
    const editor = this._editors.get(filePath)
    if (editor === undefined) {
      return
    }

    editor.destroy()
    this._editors.delete(filePath)
    this.dispatchEvent(new CustomEvent('closeFile', { detail: { filePath } }))
  }

  /**
   * Returns editor's content
   * @param filePath full path to file, identifies opened editor
   * @returns editor content
   */
  getContent (filePath: string): string {
    const editor = this._editors.get(filePath)
    if (editor === undefined) {
      throw new Error(`File ${filePath} is not opened`)
    }

    return editor.getContent()
  }

  /**
   * Forwards given API event to the corresponding Editor
   * @param filePath full path to file
   * @param evt event to forward
   */
  forwardEvent (filePath: string, evt: CustomEvent): void {
    const editor = this._editors.get(filePath)
    const action = evt.type as keyof Editor
    if (editor === undefined || typeof editor[action] !== 'function') {
      return
    }

    const handler = editor[action] as (options: unknown) => void
    handler.call(editor, evt.detail)
  }

  /**
   * Loads file to a new editor
   * @param options file options
   * @param editorElem elem to use as root for editor
   */
  loadFile (options: FileLoadOptions, editorElem: HTMLElement): void {
    const filePath = options.filePath
    const editor = new Editor({
      content: options.content,
      editorConfig: options.editorConfig,
      elem: editorElem,
      filePath,
      isReadOnly: options.isReadOnly,
      isDarkTheme: this._preferences.isDarkTheme
    })
    editor.addEventListener('stateChange', evt => {
      this.dispatchEvent(new CustomEvent('stateChange', {
        detail: { ...evt.detail, filePath }
      }))
    })
    this._editors.set(filePath, editor)

    this.dispatchEvent(new CustomEvent('loadFile', { detail: options }))
    this.dispatchEvent(new CustomEvent('stateChange', { detail: editor.getUiState() }))
  }

  /**
   * Sets app preferences
   * @param options app preferences
   */
  setPreferences (options: InputPreferences): void {
    this._htmlTheme = {
      backgroundColor: options.backgroundColor,
      textColor: options.textColor,
      highlightColor: options.highlightColor
    }

    this._preferences = {
      isDarkTheme: options.isDarkTheme ?? false,
      verticalHtmlOffset: options.verticalHtmlOffset ?? 0
    }

    for (const editor of this._editors.values()) {
      editor.setPreferences(this._preferences)
    }
    this.dispatchEvent(new CustomEvent('htmlThemeChange', { detail: this._htmlTheme }))
    this.dispatchEvent(new CustomEvent('preferencesChange', { detail: this._preferences }))
  }

  /**
   * Sets sailfish-specific app preferences
   * @param options app preferences
   */
  setSailfishPreferences (options: SeabassSailfishPreferences): void {
    this._sailfish = {
      isToolbarOpened: options.isToolbarOpened
    }
    localStorage.setItem(this.SFOS_TOOLBAR_LOCAL_STORAGE_KEY, options.isToolbarOpened.toString())
    this.dispatchEvent(new CustomEvent('sfosPreferencesChange', { detail: this._sailfish }))
  }
}
