import { LightningElement, wire, track } from 'lwc';
import getDashboardData from '@salesforce/apex/DashboardController.getDashboardData';
import { loadScript } from 'lightning/platformResourceLoader';
import ChartJS from '@salesforce/resourceUrl/ChartJS';

export default class LibraryDashboard extends LightningElement {
    @track isLoading = true;
    @track error;
    @track totalBorrowed = 0;
    @track overdueItems = 0;
    @track availableItems = 0;
    @track mostBorrowed = [];
    @track topBorrowers = [];
    chartInitialized = false;
    charts = {};

    constructor() {
        super();
        console.log('LibraryDashboard: Constructor called');
    }

    connectedCallback() {
        console.log('LibraryDashboard: Connected Callback');
    }

    renderedCallback() {
        console.log('LibraryDashboard: Rendered Callback');
        console.log('Chart Initialized:', this.chartInitialized);
        console.log('Most Borrowed:', this.mostBorrowed);
        console.log('Top Borrowers:', this.topBorrowers);

        if (!this.chartInitialized) {
            this.loadChartJS();
        }
    }

 async loadChartJS() {
    try {
        console.log('Loading Chart.js');
        await loadScript(this, ChartJS);
        this.chartInitialized = true;
        console.log('Chart.js loaded successfully');

        // Trigger chart initialization if data is already available
        if (this.mostBorrowed.length && this.topBorrowers.length) {
            this.initializeCharts();
        }
    } catch (error) {
        this.error = 'Error loading Chart.js: ' + error.message;
        console.error('Error loading Chart.js:', error);
    }
}

    @wire(getDashboardData)
    wiredDashboardData({ error, data }) {
        this.isLoading = false;
        console.log('Wired Dashboard Data - Data:', data, 'Error:', error);

        if (data) {
            this.error = undefined;
            this.processData(data);
        } else if (error) {
            this.error = 'Error loading dashboard data: ' + error.body.message;
            console.error('Error fetching dashboard data:', error);
        }
    }

    processData(data) {
        console.log('Processing Dashboard Data:', data);
        this.totalBorrowed = data.totalBorrowed;
        this.overdueItems = data.overdueItems;
        this.availableItems = data.availableItems;
        this.mostBorrowed = data.mostBorrowed || [];
        this.topBorrowers = data.topBorrowers || [];
        
        // Ensure charts are initialized if Chart.js is already loaded
        if (this.chartInitialized) {
            window.requestAnimationFrame(() => {
                this.initializeCharts();
            });
        } else {
            // If Chart.js isn't loaded yet, try to load it
            this.loadChartJS();
        }
    }

    initializeCharts() {
        console.log('Initializing Charts');
        this.destroyCharts();
        
        try {
            requestAnimationFrame(() => {
                // Only create charts if we have data
                if (this.mostBorrowed.length) {
                    this.createMostBorrowedChart();
                }
                if (this.topBorrowers.length) {
                    this.createTopBorrowersChart();
                }
            });
        } catch (error) {
            this.error = 'Error creating charts: ' + error.message;
            console.error('Error creating charts:', error);
        }
    }

    createMostBorrowedChart() {
        const canvas = this.template.querySelector('canvas.mostBorrowedChart');
        if (!canvas) {
            console.error('Most Borrowed Chart canvas not found');
            return;
        }

        try {
            const ctx = canvas.getContext('2d');
            this.charts.mostBorrowed = new Chart(ctx, {
                type: 'bar',
                data: {
                    labels: this.mostBorrowed.map(item => item.name),
                    datasets: [{
                        label: 'Most Borrowed Items',
                        data: this.mostBorrowed.map(item => item.count),
                        backgroundColor: 'rgba(54, 162, 235, 0.5)',
                        borderColor: 'rgba(54, 162, 235, 1)',
                        borderWidth: 1
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    animation: {
                        duration: 1000
                    },
                    scales: {
                        y: { 
                            beginAtZero: true,
                            ticks: {
                                precision: 0
                            }
                        }
                    },
                    plugins: {
                        title: {
                            display: true,
                            text: 'Most Borrowed Items'
                        }
                    }
                }
            });
        } catch (error) {
            console.error('Error creating Most Borrowed Chart:', error);
        }
    }

    createTopBorrowersChart() {
        const canvas = this.template.querySelector('canvas.topBorrowersChart');
        if (!canvas) {
            console.error('Top Borrowers Chart canvas not found');
            return;
        }

        try {
            const ctx = canvas.getContext('2d');
            this.charts.topBorrowers = new Chart(ctx, {
                type: 'pie',
                data: {
                    labels: this.topBorrowers.map(borrower => borrower.name),
                    datasets: [{
                        data: this.topBorrowers.map(borrower => borrower.count),
                        backgroundColor: [
                            'rgba(255, 99, 132, 0.8)',
                            'rgba(54, 162, 235, 0.8)',
                            'rgba(255, 206, 86, 0.8)'
                        ]
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    animation: {
                        duration: 1000
                    },
                    plugins: {
                        title: {
                            display: true,
                            text: 'Top Borrowers'
                        }
                    }
                }
            });
        } catch (error) {
            console.error('Error creating Top Borrowers Chart:', error);
        }
    }

    destroyCharts() {
        Object.values(this.charts).forEach(chart => {
            if (chart) chart.destroy();
        });
        this.charts = {};
    }

    disconnectedCallback() {
        this.destroyCharts();
    }
}