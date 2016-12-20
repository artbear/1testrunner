#!groovy
node("slave") {
    // ВНИМАНИЕ:
    // Jenkins и его ноды нужно запускать с кодировкой UTF-8
    //      строка конфигурации для запуска Jenkins
    //      <arguments>-Xrs -Xmx256m -Dhudson.lifecycle=hudson.lifecycle.WindowsServiceLifecycle -Dmail.smtp.starttls.enable=true -Dfile.encoding=UTF-8 -jar "%BASE%\jenkins.war" --httpPort=8080 --webroot="%BASE%\war" </arguments>
    //
    //      строка для запуска нод
    //      @"C:\Program Files (x86)\Jenkins\jre\bin\java.exe" -Dfile.encoding=UTF-8 -jar slave.jar -jnlpUrl http://localhost:8080/computer/slave/slave-agent.jnlp -secret XXX
    //      подставляйте свой путь к java, порту Jenkins и секретному ключу
    //
    // Если запускать Jenkins не в режиме UTF-8, тогда нужно поменять метод cmd в конце кода, применив комментарий к методу

    def isUnix = isUnix();

    stage "checkout"

    // if (isUnix && !env.DISPLAY) {
    //    env.DISPLAY=":1"
    // }
    
    checkout scm
    cmd('git config --system core.longpaths')
    
    stage "test"

    // dir('tests') {
    def commandToRun = """oscript testrunner.os -runall tests xddReportPath tests""";
    // если использовать oscript -encoding=utf-8, то использовать в Jenkins на Windows ни одно переключение кодировок через chcp ХХХ не даст правильную кодировку, все время будут иероглифы !!
    // в итого в Jenkins на Windows нужно запускать oscript без -encoding=utf-8  

    cmd(commandToRun)
    // }

    step([$class: 'JUnitResultArchiver', testResults: '**/tests/*.xml'])

}

def cmd(command) {
    // TODO при запуске Jenkins не в режиме UTF-8 нужно написать chcp 1251 вместо chcp 65001
    if (isUnix()){ sh "${command}" } else {bat "chcp 65001\n${command}"}
}
