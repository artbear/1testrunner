#!groovy
node("slave") {
    def isUnix = isUnix();

    stage "checkout"

    // if (isUnix && !env.DISPLAY) {
    //    env.DISPLAY=":1"
    // }
    
    checkout scm
    if (isUnix) {sh 'git submodule update --init'} else {bat "git submodule update --init"}
    
    stage "test"

    // dir('tests') {
    def commandToRun = """oscript testrunner.os -runall tests xddReportPath tests""";
    // если использовать oscript -encoding=utf-8, то использовать в Jenkins на Windows ни одно переключение кодировок через chcp ХХХ не даст правильную кодировку, все время будут иероглифы !!
    // в итого в Jenkins на Windows нужно запускать oscript без -encoding=utf-8  

    if (isUnix){
        sh "${commandToRun}"
    } else {
        bat "@chcp 1251 > nul \n${commandToRun}"
    }    
    // }

    step([$class: 'JUnitResultArchiver', testResults: '**/tests/*.xml'])

}