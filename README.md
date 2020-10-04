Per l'installazione dei servizi CAS su cloud è necessario procurarsi un account Amazon Web Service per sfruttare nello specifico il servizio di cloud hosting EC2.
Se possibile è consiglisto l'utilizzo di un account AWS Educate in quanto permette di iniziare con un fondo di 100 €.

# Configurazione di una istanza EC2
CAS sarà ospitato su un'istanza EC2 che però prima necessita di essere configurata. Di seguito i settaggi:

**Sistema operativo.** Il primo passo per configurare l’istanza è scegliere l’AMI€
(Amazon Machine Image) ovvero il sistema operativo che girerà sul’istanza. Per la macchina che hosterà CAS scegliamo Ubuntu 16.04 poichè è un
buon compromesso tra un sistema operativo aggiornato in grado di far girare
applicazoni recenti e un sistema operativo leggero.
Tipo di istanza e memoria di storage. Il secondo passo è scegliere la tipologia dell’istanza a seconda delle prestazioni richieste dall’applicazione. Per
il deploy di CAS è sufficiente una istanza EC2 di tipo T2, tipologia per un
utilizzo generico e a basso costo, di classe media (t2.medium). Tale istanza è dotata di due core e 4 GiB di memoria RAM. Per quanto riguarda lo
storage abbiamo la possibilità di scegliere quanta memoria dedicare alla nostra istanza. Si utilizza Amazon Elastic Block Store (EBS) un servizio di
storage a blocchi ad alte prestazioni progettato per l’utilizzo con Amazon Elastic Compute Cloud. Elastic Volumes è una caratteristica che permette
di ottimizzare con la massima semplicità i volumi in base alle esigenze di
un’applicazione. Questa caratteristica consente di potenziare dinamicamente la capacità, ottimizzare le prestazioni e modificare il tipo di volumi senza
tempi di inattività o ripercussioni sulle prestazioni. Le immagini Docker che
compongono CAS hanno un peso di circa 9 gigabyte ed è necessario dedicare
spazio anche ai database che i vari servizi utilizzano. Vengono quindi allocati
14 GiB di memoria per lo storage che, come detto poc’anzi, sono riallocabili
grazie alla tecnologia EBS.

**Gruppo di sicurezza.** Il terzo passo consiste nel configurare quello che all’interno della console EC2 è denominato Gruppo di Sicurezza. Si tratta di una
sorta di firewall virtuale che viene definito da un insieme di regole riguardanti i principali protocolli di rete come TCP, HTTP, SSH, sia sul traffico in
entrata sia sul traffico in uscita. Nel caso di CAS vengono lasciate di default
le regole in uscita e vengono definite solo regole in entrata: le porte TCP e
UDP vengono rese accessibili da qualsiasi IP in modo tale da rendere l’applicazione raggiungibile da ogni dispositivo mentre l’accesso ssh, necessario
per raggiungere la shell dell’istanza, è reso esclusivo allo sviluppatore CAS
esplicitando l’IP della sua macchina.

**Coppia di chiavi.** Prima di avviare l’istanza viene creata una coppia di chiavi,
in formato .pem dove Amazon EC2 memorizza la chiave pubblica e chi si
occupa di accedere alla shell dell’istanza memorizza la chiave privata. La
chiave privata è necessaria per connettersi all’istanza tramite client SSH.

**Indirizzo IP elastico.** Un indirizzo IP elastico è un indirizzo IPv4 statico, pubblico e raggiungibile da Internet, progettato per il cloud computing dinamico.
Gli indirizzi IP elastici vengono prelevati dal pool di indirizzi publici di Amazon e possono essere assegnati ad una istanza. Se non viene assegnato alcun
IP elastico, ad ogni riavvio dell’istanza viene assegnato a quest’ultima un
indirizzo scelto in maniera randomica dal pool di Amazon. È quindi fondamentale assegnare un IP elastico all’istanza che ospita CAS in modo tale da rendere l’indirizzo publico del servizio costante nel tempo dato che indirizzo
IP elastico rimane associato all’istanza fino all’esplicito rilascio.



# Installazione dei servizi CAS tramite CAS Installer

È possibile installare i servizi CAS sull'istanza EC2 in pochi comandi tramite un file script CAS Installer, scritto per essere utilizzato su sistemi operativi Ubuntu. 
Il file si occupa di scaricare dal GitHub i file Docker per ogni servizio e di buildare le immagini dando origine ai container. 
Inoltre tramite lo script è possibile eseguire lo start, lo stop e la rimozione di tutti i container in una volta.


In primo luogo è necessario assicurarsi che, dove si sta installando CAS, siano presenti gli elementi fondamentali per l’installazione e per la creazione dei container. Si tratta di Git, Docker Engine e Docker Compose. 

Documentazione per l’installazione:
* Git (apt-get install git) → https://book.git-scm.com/download/linux
* Docker Engine → https://docs.docker.com/engine/install/ubuntu/
* Docker Compose → https://docs.docker.com/compose/install/

Lo script è scaricabile direttamente da linea di comando eseguendo il clone da GitHub:
git clone https://github.com/ciambialonso/cas-installer.git   .
Dopo aver eseguito il clone verrà scaricata una cartella denominata cas-installer e contenente il file script *cas.bash* .
Il file script viene eseguito tramite il comando *bash cas.bash [OPSTIONS]*. Se lasciato vuoto il campo OPSTIONS, viene restituita in output la lista di tutte le opzioni disponibili, mentre se riempito  in modo corretto vengono richiamate le diverse funzioni contenute nello script. Utilizzato l’opzione *-i* ( *bash cas.bash -i* ) si esegue l’installazione dei servizi CAS, utilizzando *-r* vengono avviati i container e così via. Inoltre, in fase di installazione, lo script si occupa di verificare che siano presenti i requisiti per l’installazione dei servizi.
Una volta terminato il comando di installazione vengono scaricate diverse directory, una per ogni servizio, denominate *cas-nome_servizio*. All’interno di ciascuna directory saranno presenti i file Docker, Docker Compose e file di configurazione. Successivamente eseguendo *bash cas.bash -r* i container vengono avviati. Per verificare che tutti i container siano in esecuzione e tramite che numero di porta sono accessibili si può lanciare il comando *docker ps*.



# Accesso ai servizi tramite browser

Per accedere ai servizi, sia che siano installati in locale sia che siano installati su (cloud) server, è sufficiente digitare l’indirizzo IP della macchina che si occupa di hostare i container e affiancare il numero di porta specifico di ciascun servizio. Es. ip_host:2080

* Gitlab → 1080
* Taiga.io → 2080
* attermost → 3080
* Sonarqube → 4080
* Bugzilla → 5080
