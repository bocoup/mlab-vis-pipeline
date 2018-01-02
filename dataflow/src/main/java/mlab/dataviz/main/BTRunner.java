package mlab.dataviz.main;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import mlab.dataviz.pipelines.BigtableTransferPipeline;

public class BTRunner {
	private static final Logger LOG = LoggerFactory.getLogger(BTRunner.class);
	public static void main(String[] args) throws InterruptedException {

		LOG.info(">>> Starting Pipeline Runner server");
		MetricsServer m = new MetricsServer();
		BigtableTransferPipeline btp = new BigtableTransferPipeline(args);

		// Bigtable pipeline thread
		Thread bigtablePipeline = new Thread(btp);

		// Prometheus http server
		Thread metricsThread = new Thread(m);

		metricsThread.start();
		bigtablePipeline.start();

		LOG.info(">>> Metrics server running");
		LOG.info(">>> Starting new bigtable thread");

		// default number of days at which to run the bt pipeline
		float everyNDays = 3;
		String everyNDaysEnv = System.getenv("RUN_BT_UPDATE_EVERY");
		if (everyNDaysEnv != null) {
			everyNDays = Float.parseFloat(everyNDaysEnv);
		}

		while (metricsThread.isAlive()) {
			Thread.sleep((long) Math.round(8.64e+7 * everyNDays)); // 1 day's milliseconds * # of days
			LOG.info(">>> Wake up to check if Bigtable pipeline still running.");
			Thread.sleep(1000);
			System.out.println("Checking in");

			// restart day pipeline
			if (!bigtablePipeline.isAlive()) {
				LOG.info(">>> Starting new bigtable thread");
				bigtablePipeline = new Thread(btp);
				bigtablePipeline.start();
			} else {
				LOG.info(">>> Bigtable Pipeline still running. Going back to sleep.");
			}
		}
	}
}
