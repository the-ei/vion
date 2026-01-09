The first day yielded fragments.

Kevin Zhou worked through his normal tasks with half his attention while the other half traced SIEVE through Prometheus's infrastructure. The project appeared in glimpses—a reference in a configuration file, a log entry that mentioned the name before routing to an inaccessible destination, a code comment left by someone who had worked on integration and forgotten to scrub their notes. Each fragment was small, meaningless in isolation, but Kevin Zhou was patient. He had learned patience from years of debugging systems that didn't want to reveal their secrets.

The comment led to a developer: someone on a different team, one floor up, working on partner integrations. Kevin Zhou didn't know them personally, but their code style was distinctive—clean, methodical, the kind of work that came from someone who took pride in craftsmanship. The developer had written an authentication module that connected Prometheus inference services to external APIs. The module included a parameter for "project routing," and one of the valid values was SIEVE.

From there, Kevin Zhou found the API endpoints. Three of them, documented only in internal configuration files he shouldn't have had access to but did because infrastructure engineers needed to see everything to maintain anything. The endpoints accepted inference requests, processed them through Prometheus models, and returned responses that included additional fields: confidence scores, category labels, "decision recommendations."

The names of the external partners were encrypted, but Kevin Zhou could see the traffic patterns. High volume, steady flow, no spikes that would suggest experimental use. Whatever SIEVE was doing, it was doing it at scale, in production, for partners who depended on it for something that mattered.

He documented everything. Not in the official systems—he wasn't ready to file a ticket, wasn't sure what he would even say—but in encrypted notes on his personal machine, evidence accumulating like sediment.


---

The second day brought the breakthrough.

Kevin Zhou found the log aggregator. It was buried in a subsystem he maintained but rarely examined, a legacy component that had survived three architecture migrations. The aggregator collected inference statistics from all production systems, including SIEVE. Most of the data was encrypted, inaccessible, but the aggregator also tracked metadata: request counts, latency distributions, error rates. And in the metadata, Kevin Zhou found something that made him stop.

The SIEVE endpoints served four categories of partners. The categories were labeled only by code—A7, B3, C2, D5—but Kevin Zhou could see the traffic volumes for each. Category A7 was the largest by far, processing millions of requests per day. Category B3 was smaller but growing rapidly. The other two were modest in comparison.

He cross-referenced the category codes against the external partner database, using the same configuration files that had revealed the endpoints. The database was encrypted, but the encryption was handled by a key management system he had legitimate access to—one of the tools he needed to rotate API credentials and manage certificates. He generated a temporary key, decrypted the partner mappings, and saw what SIEVE was actually doing.

A7: Healthcare systems. Insurance companies. Hospital networks.

B3: Financial services. Banks, lenders, credit agencies.

C2: Employers. HR platforms, background check services, gig economy apps.

D5: Government. Criminal justice systems, social services, immigration databases.

The inference requests flowed from these partners to Prometheus, were processed by SIEVE, and returned with decision recommendations. Not just predictions—recommendations. The algorithm was telling healthcare systems who to prioritize. Telling banks who to lend to. Telling employers who to hire. Telling governments who to investigate, who to detain, who to release.


---

Kevin Zhou stared at his screen. The office was quiet around him—late afternoon, most of his colleagues gone for the day, the building settling into its evening emptiness. The monitors cast blue light on his face, and the data glowed with implications he was still trying to understand.

He knew, abstractly, that Prometheus technology powered external systems. That was the business model: build foundational AI capabilities and license them to partners who built applications on top. It was legal, profitable, unremarkable. Every major AI company did the same thing.

But SIEVE wasn't just inference. It wasn't just prediction. The recommendations had a structure that suggested something more—a coordination layer, a logic that connected decisions across domains. A healthcare recommendation that influenced a financial decision. A financial decision that influenced an employment outcome. An employment outcome that influenced a government assessment. The categories weren't isolated. They were linked.

He thought about the models he helped maintain. The serving infrastructure he had optimized for scale and reliability. The APIs he had made faster, more efficient, more capable of processing millions of requests per day. He had always understood his work abstractly—building systems that enabled other systems, serving models that served purposes he didn't need to know. It was comfortable, that abstraction. It was safe.

Now the abstraction was dissolving. The models he maintained were being used to sort people. The infrastructure he had built was processing decisions about who got healthcare, who got loans, who got jobs, who got freedom. He had made the machine faster, and the machine was deciding who deserved what.


---

The third day, Kevin Marsh appeared at his desk.

Kevin Marsh was his manager—a pleasant man in his forties, technical background but now mostly administrative, the kind of person who had risen by being reliable rather than brilliant. He stood at the edge of Kevin Zhou's workspace, coffee cup in hand, his expression carefully casual.

"Working late a lot this week," he said.

Kevin Zhou minimized his terminal windows with a deliberate absence of speed—nothing to hide, nothing to reveal. "Infrastructure issues. The latency problem from Monday cascaded into some monitoring gaps."

"Ah." Kevin Marsh nodded, as if this explained something. "Well, don't burn yourself out. You're valuable here. We need you sustainable."

"I appreciate that."

"Also—" Kevin Marsh hesitated, the casualness slipping slightly. "I noticed some unusual query patterns coming from your access credentials. System security flagged them. Probably nothing, but I wanted to check in."

The words landed precisely where they were meant to land. Kevin Zhou's expression didn't change. "I've been tracing some anomalies in resource allocation. Cross-referencing documentation. Standard debugging."

"Standard debugging doesn't usually involve the external partner database."

A pause. Kevin Zhou met his manager's eyes and saw something there—not suspicion exactly, but awareness. Kevin Marsh knew something. Maybe not everything, but enough to be asking questions.

"I'll be more careful about scope," Kevin Zhou said. "I didn't realize the partner database was flagged."

"It's not. Usually." Kevin Marsh took a sip of his coffee. "Just be careful, okay? Some projects have access controls for good reasons. It's better not to dig where you don't need to dig."

He walked away. Kevin Zhou watched him go, then turned back to his screens, heart beating slightly faster than it should have been.

He was being watched. Someone knew.


---

That night, he worked from home. The investigation had become something else now—not idle curiosity but deliberate excavation, the knowledge that what he was looking for mattered, that someone wanted it hidden, that finding it might cost him something.

Kevin Zhou was not, by nature, a rebel. He had spent his entire career following rules, meeting expectations, being the kind of employee who was valued precisely because he didn't cause problems. He had left China at eighteen, earned his degrees in American universities, built a life in a country that had given him opportunity in exchange for his talent, and he had never questioned the exchange. The work was interesting. The money was good. The system functioned, and he functioned within it.

But SIEVE had changed something. Or maybe the change had been waiting, dormant, and SIEVE had only revealed it. Seeing the partner categories—healthcare, finance, employment, government—had made the abstraction concrete. These weren't hypothetical systems making hypothetical decisions. They were real, operating now, affecting people whose lives would be shaped by algorithms Kevin Zhou had helped build.

He traced more connections. Found references to something called "Vertex Analytics"—a name that appeared in integration documentation, a partner that seemed to specialize in aggregating Prometheus capabilities for specific applications. Vertex was one of the intermediaries, a layer between Prometheus and the end users, obscuring the direct connection while profiting from it.

The scope was larger than he had imagined. SIEVE wasn't a project—it was an ecosystem. A network of partners and applications all feeding on the same infrastructure, all using the same models, all implementing the same logic of sorting and scoring and deciding who deserved what.

And at the center of it all, providing the intelligence, the capability, the power to process millions of decisions per day: Prometheus Systems.

Kevin Zhou's employer. His work. His identity.

He saved his notes. He closed his laptop. He sat in his empty apartment, surrounded by nothing that revealed who he was, and felt something shift inside him that he couldn't name.


---

The fourth day, Kevin Zhou made a decision.

He would keep investigating. He would be more careful—use VPNs, obfuscate his queries, avoid the patterns that had triggered the security alerts. But he wouldn't stop. The knowledge was too important, the implications too significant. Someone needed to understand what SIEVE was doing, and he was perhaps the only person at Prometheus with both the technical expertise and the willingness to look.

Why him? He didn't know. Perhaps it was the accident of discovering the anomaly, the arbitrary timing of a routine monitoring check. Perhaps it was something deeper—a conscience he had suppressed for years finally asserting itself, the ghost of the student who had come to America believing in something and had learned to believe in nothing but work.

He thought about his parents in Shenzhen, the calls that failed to connect, the distance that had grown into estrangement. He thought about the country he had left and the one he had joined, both of them vast and indifferent, both of them building systems that sorted and controlled and decided. He thought about the people whose lives were being shaped by algorithms he had helped create—strangers, anonymous, reduced to data points and probability scores.

They weren't abstractions anymore. That was the change. They had faces now, even if he couldn't see them. They had lives that would be better or worse because of what he had built.

Kevin Zhou opened his laptop. He navigated to the internal documentation system, the one that tracked ethics reviews and compliance assessments. He searched for SIEVE and found nothing—no reviews, no assessments, no evidence that anyone had asked whether this system should exist.

But in the related documents, a name appeared. Someone who had signed off on partner integration ethics reviews, someone whose role was to ensure Prometheus technology was used responsibly.

Ananya Ramaswamy. VP of AI Ethics.

Kevin Zhou wrote down the name. One more thread to follow. One more piece of a puzzle that was beginning to reveal its shape.


---

