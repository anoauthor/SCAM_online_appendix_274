import java 
import codeql_queries.java.MongoOperations.mongoOperations





class ProjectMethod extends Method {
    ProjectMethod(){
        exists(File file | 
            file.getExtension().matches("java") and
            this.getFile() = file)
    }
}

class ProjectMongoMethod extends ProjectMethod {
    ProjectMongoMethod(){
        exists(MongoMethodCall mmc |
            mmc.getEnclosingCallable() = this )
    }
}

float getNumberProjectsMethods() {
    result = count(ProjectMethod mongoMethods)
}

float getNumberProjectsMongoMethods() {
    result = count(ProjectMongoMethod mongoMethod)
}


float getPercentageMethodsUsingMongo(){
    result = (getNumberProjectsMongoMethods() / getNumberProjectsMethods()) * 100
}

/*from ProjectMongoMethod method
where getPercentageMethodsUsingMongo() > 10
select method, getPercentageMethodsUsingMongo()*/
/*bindingset[collectionName]
MongoMethodCall getCallByCollectionName(string collectionName){
    exists(MongoMethodCall call |
        call.getCollectionName().matches(collectionName) and
        result = call)
}*/


int distanceBetweenFile(File file1, File file2){
    if file1 = file2
    then result = 0
    else 
        if file1.getParentContainer().getAFile() = file2 or file2.getParentContainer().getAFile() = file1
        then result = 1
        else
            if file1.getParentContainer().getAFolder().getAFile() = file2 or file2.getParentContainer().getAFolder().getAFile() = file1
            then result = 2
            else 
                result = 3
}

from MongoMethodCall call, File file
where not call.getCollectionName().matches("Unknown") and
    file = call.getFile() and
    exists(MongoMethodCall mongoCall | 
        call.getCollectionName().matches(mongoCall.getCollectionName()) and
        mongoCall != call and
        distanceBetweenFile(file, mongoCall.getFile()) > 2)
select call, call.getCollectionName() as collectionName, call.getFile().getAbsolutePath()
order by collectionName asc

/*from File file1, File file2
where distanceBetweenFile(file1, file2) < 3 and
        file1.getExtension().matches("java") and
        file2.getExtension().matches("java") and
        file1.getBaseName().matches("Main.java")
select file1, file2, distanceBetweenFile(file1, file2)*/




/*int getDepth(File file){
    result = count(Folder container |
        container = file.getParentContainer*())
}*/

/*XMLFile firstPomFile(File file){

}*/

/*class MongoCallFile extends File {
    MongoCallFile(){
        exists(MongoMethodCall call |
            call.getFile() = this and 
            this.getExtension().matches("java")
        ) 
    }
}*/

/*from  MongoCallFile file, Folder parent, XMLFile pomFile 
where parent = file.getParentContainer*()
    and pomFile = parent.getAFile()
    and getDepth(pomFile) = max(Folder sparent, XMLFile spomFile, int depth|
        sparent = file.getParentContainer*()
        and spomFile = sparent.getAFile()
        and depth = getDepth(spomFile) | depth)
select file, file.getAbsolutePath() ,pomFile, getDepth(pomFile)*/



/*int getDepth(File file){
    result = count(Folder container |
        container = file.getParentContainer*())
}

class PomFile extends XMLFile {
    PomFile(){
        this.getBaseName().matches("pom.xml")
    }
}

class MongoCallFile extends ProjectFile {
    MongoCallFile(){
        exists(MongoMethodCall call |
            call.getFile() = this and 
            this.getExtension().matches("java")
        ) 
    }

    Folder commonAncestor(){
        forall(MongoCallFile mongoCallFile |
            exists(Folder folder |  
                folder.getAChildContainer*() = mongoCallFile and
                result = folder
            )       
        )
            
    }
}

class ProjectFile extends File {
    ProjectFile(){
        exists(ProjectFolder folder, File file | 
            not testAndMigrationFile(file.getFile()) and
            file = folder.getAChildContainer*() and
            not file.getExtension().matches("class") and
            this = file)
    }

    int getDepthInProject(){
        exists(ProjectFolder projectFolder |
            result = count(Folder container |
                container = this.getParentContainer*() and 
                container = projectFolder.getAChildContainer*())
        )
    }
}




class ProjectFolder extends Folder{
    ProjectFolder(){
        exists(PomFile projectPomFile | 
            not exists(PomFile pomFile |
                getDepth(projectPomFile) > getDepth(pomFile))
            and this = projectPomFile.getParentContainer())
    }

    /*ProjectFile getMongoCallFile(){
        exists(ProjectFile file |
            file.getExtension().matches("java") and
            result = file
        )
    }

    ProjectFile getProjectFile(){
        exists(File file |
            file = this.getAChildContainer*() and 
            not file.getExtension().matches("class") and
            result = file
        )
    }

    int maxDeph(){
        result = max(ProjectFile projectFile ,int nbDepth |
            nbDepth = projectFile.getDepthInProject() | nbDepth) 
    }


    float depthAverage(){
        result = avg(ProjectFile projectFile ,int nbDepth |
            nbDepth = projectFile.getDepthInProject() | nbDepth)
    }

    float depthMongoCallFileAverage(){
        result = avg(MongoCallFile projectFile ,int nbDepth |
            nbDepth = projectFile.getDepthInProject() | nbDepth)
    }
}

from ProjectFile projectFile, MongoCallFile mongoCallFile
select projectFile*/

/*int depthInProject(Folder folder){
    exists(ProjectFolder projectFolder |
        result = count(Folder container |
            container = folder.getParentContainer*() and 
            container = projectFolder.getAChildContainer*())
    )
}

from MongoCallFile file, Folder folder
where 
    folder = file.getParentContainer*() and
    forall(MongoCallFile files | 
        files.getParentContainer*() = folder) and
    depthInProject(folder) = max(MongoCallFile filee ,Folder folderr, int depth |
        folderr = filee.getParentContainer*() and
        forall(MongoCallFile files | 
            files.getParentContainer*() = folderr) and
        depth = depthInProject(folderr) | depth)
select file, folder, depthInProject(folder)*/

/*from Folder folder
select folder, depthInProject(folder)*/

