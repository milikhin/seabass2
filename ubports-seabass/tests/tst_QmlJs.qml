import QtQuick 2.0
import QtTest 1.0

import "../qml/generic/utils.js" as QmlJs

Item {
  TestCase {
    name: '#getDirPath'

    function test_sliceFileName() {
      var filePath = '/foo/bar/baz'
      var result = QmlJs.getDirPath(filePath)
      compare(result, '/foo/bar', 'Should remove file name')
    }
  }

  TestCase {
    name: '#getFileName'

    function test_extractFileName() {
      var filePath = '/foo/bar/baz'
      var result = QmlJs.getFileName(filePath)
      compare(result, 'baz', 'Should extract file name')
    }
  }

  TestCase {
    name: "#getNormalPath"
    readonly property string correctPath: '/foo/bar'

    function test_removeTrailingSlash() {
      var dirPath = '/foo/bar/'
      var result = QmlJs.getNormalPath(dirPath)
      compare(result, correctPath, 'Should remove trailing \'/\'')
    }

    function test_removeLeadingFileScheme() {
      var dirPath = 'file:///foo/bar'
      var result = QmlJs.getNormalPath(dirPath)
      compare(result, correctPath, 'Should remove leading file://')
    }
  }

  TestCase {
    name: "#getPrintableDirPath"
    readonly property string homeDir: '/home/user'

    function test_addSlashToDirName() {
      var filePath = '/foo/bar'
      var result = QmlJs.getPrintableDirPath(filePath, homeDir, false)
      compare(result, '/foo/bar/', 'Should add / after directory name')
    }

    function test_replaceHomeWithTilda() {
      var result = QmlJs.getPrintableDirPath(homeDir, homeDir)
      compare(result, '~/', 'Should replace $HOME width ~')
    }
  }

  TestCase {
    name: "#isDarker"
    readonly property string homeDir: '/home/user'

    function test_blackVsWhite() {
      var lightColor = '#ffffff'
      var darkColor = '#000000'
      var result = QmlJs.isDarker(darkColor, lightColor)
      compare(result, true, 'Black should be darker than white')
    }

    function test_whiteVsBlack() {
      var lightColor = '#ffffff'
      var darkColor = '#000000'
      var result = QmlJs.isDarker(lightColor, darkColor)
      compare(result, false, 'White should NOT be darker than black')
    }
  }

  TestCase {
    name: "#readFile"
    readonly property string expectedContent: 'foo'
    readonly property string filePath: Qt.resolvedUrl('./data/test.txt')

    function test_readFile() {
      var readContent = ''
      QmlJs.readFile(filePath, function(err, content) {
        if (err) {
          console.error(err)
          return
        }

        readContent = content
      })
      tryVerify(function() { return readContent === expectedContent }, 1000, 'Should read content from a given file')
    }
  }

  TestCase {
    name: "#writeFile"
    readonly property string expectedContent: Math.random()
    readonly property string filePath: Qt.resolvedUrl('./data/test_write.txt')

    function test_writeFile() {
      var readContent = ''
      QmlJs.writeFile(filePath, expectedContent, function(err, content) {
        if (err) {
          console.error(err)
          return
        }

        QmlJs.readFile(filePath, function(err, content) {
          if (err) {
            console.error(err)
            return
          }

          readContent = content
        })
      })
      
      tryVerify(function() { return readContent === expectedContent }, 1000, 'Should write given content to a file')
    }
  }
}
