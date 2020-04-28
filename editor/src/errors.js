class BaseError extends Error {
  constructor (name, message) {
    super()
    Error.captureStackTrace(this, this.constructor)

    this.message = message
    this.name = name
  }
}

export class InvalidArgError extends BaseError {
  constructor (message) {
    super('InvalidArgError', message)
  }
}
