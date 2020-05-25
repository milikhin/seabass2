class BaseError extends Error {
  constructor (name, message) {
    super()

    this.message = message
    this.name = name
  }
}

export class InvalidArgError extends BaseError {
  constructor (message) {
    super('InvalidArgError', message)
  }
}

export class NotFoundError extends BaseError {
  constructor (message) {
    super('NotFoundError', message)
  }
}
